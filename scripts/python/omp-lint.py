from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


ANCHOR_PATTERN = re.compile(r"^M\d{2}-P\d{2}-A\d{2}$")
OUTPUT_LEAK_PATTERN = re.compile(r"M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref|data-anchor")
HTML_MARKER_PATTERN = re.compile(r'data-anno=["\']([^"\']+)["\']|showAnno\(["\']([^"\']+)["\']')
MANIFEST_SCHEMA_PATH = "contracts/schemas/solution.manifest.schema.json"
REVIEW_PACK_SCHEMA_PATH = "contracts/schemas/review-pack.schema.json"
STATUS_SCHEMA_PATH = "contracts/schemas/status.schema.json"


def resolve_path(raw: str) -> Path:
    path = Path(raw)
    return path if path.is_absolute() else (Path.cwd() / path).resolve()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def load_json(path: Path) -> Any:
    return json.loads(read_text(path))


def dump(payload: dict[str, Any], exit_code: int = 0) -> int:
    sys.stdout.write(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    return exit_code


def fail(tool: str, errors: list[str], warnings: list[str] | None = None, checked: list[str] | None = None) -> int:
    return dump({"tool": tool, "result": "fail", "errors": errors, "warnings": warnings or [], "checked": checked or []}, 1)


def ensure(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def validate_status_shape(payload: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    required_top = ["current_mode", "current_stage", "context_package", "baselines", "artifacts", "alignment_state", "fallback_state", "change_state", "review_state", "anchors_state"]
    for field in required_top:
        ensure(field in payload, f"status 缺少字段：{field}", errors)
    if errors:
        return errors, warnings
    context = payload["context_package"]
    for field in ["request_summary", "solution_shape", "business_stage", "system_or_page_clues", "material_paths", "context_gaps"]:
        ensure(field in context, f"context_package 缺少字段：{field}", errors)
    shape = str(context.get("solution_shape", "")).strip()
    if shape and shape not in {"iteration", "new_build", "hybrid"}:
        errors.append(f"context_package.solution_shape 非法：{shape}")
    change = payload["change_state"]
    if change.get("change_category", "") and change.get("change_category") not in {"minor_patch", "within_module", "new_module", "structural_change"}:
        errors.append(f"change_state.change_category 非法：{change.get('change_category')}")
    review_state = payload["review_state"]
    ensure("must_fix_before_next_stage" in review_state, "review_state 缺少字段：must_fix_before_next_stage", errors)
    anchors_meta = payload["anchors_state"].get("meta", {})
    for field in ["version", "anchor_manifest", "open_questions", "confirmed_facts", "can_progress"]:
        ensure(field in anchors_meta, f"anchors_state.meta 缺少字段：{field}", errors)
    return errors, warnings


def validate_manifest_shape(payload: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for field in ["solution_shape", "current_version", "modules"]:
        ensure(field in payload, f"manifest 缺少字段：{field}", errors)
    modules = payload.get("modules") or []
    ensure(isinstance(modules, list) and len(modules) > 0, "manifest.modules 为空", errors)
    for module in modules:
        ensure(bool(module.get("module_id")), "模块缺少 module_id", errors)
        ensure(bool(module.get("module_name")), f"模块缺少 module_name：{module.get('module_id', '')}", errors)
        pages = module.get("pages") or []
        ensure(isinstance(pages, list) and len(pages) > 0, f"模块缺少 pages：{module.get('module_id', '')}", errors)
        for page in pages:
            ensure(bool(page.get("page_id")), f"页面缺少 page_id：{module.get('module_id', '')}", errors)
            ensure(bool(page.get("page_name")), f"页面缺少 page_name：{module.get('module_id', '')}/{page.get('page_id', '')}", errors)
            actions = page.get("actions") or []
            ensure(isinstance(actions, list) and len(actions) > 0, f"页面缺少 actions：{module.get('module_id', '')}/{page.get('page_id', '')}", errors)
            for action in actions:
                anchor_id = str(action.get("anchor_id", "")).strip()
                ensure(bool(anchor_id), f"动作缺少 anchor_id：{module.get('module_id', '')}/{page.get('page_id', '')}", errors)
                if anchor_id and not ANCHOR_PATTERN.match(anchor_id):
                    errors.append(f"anchor_id 格式非法：{anchor_id}")
                ensure(bool(action.get("action_name")), f"动作缺少 action_name：{anchor_id or page.get('page_id', '')}", errors)
                ensure("prd_locator" in action, f"动作缺少 prd_locator：{anchor_id or page.get('page_id', '')}", errors)
                ensure("prototype_locator" in action, f"动作缺少 prototype_locator：{anchor_id or page.get('page_id', '')}", errors)
    return errors, warnings


def validate_review_pack_shape(payload: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for field in ["generated_at", "status_summary", "baselines", "traceability", "lint_results", "review_inputs"]:
        ensure(field in payload, f"review-pack 缺少字段：{field}", errors)
    return errors, warnings


def run_shape_validation(target: str, file_path: Path) -> dict[str, Any]:
    payload = load_json(file_path)
    validator_map = {"status": validate_status_shape, "manifest": validate_manifest_shape, "review-pack": validate_review_pack_shape}
    schema_map = {"status": STATUS_SCHEMA_PATH, "manifest": MANIFEST_SCHEMA_PATH, "review-pack": REVIEW_PACK_SCHEMA_PATH}
    errors, warnings = validator_map[target](payload)
    return {
        "tool": "schema-check",
        "target": target,
        "schema": schema_map[target],
        "result": "fail" if errors else "warn" if warnings else "pass",
        "errors": errors,
        "warnings": warnings,
        "checked": [str(file_path)],
    }


def schema_check(args: argparse.Namespace) -> int:
    file_path = resolve_path(args.file)
    if not file_path.exists():
        return fail("schema-check", [f"文件不存在：{args.file}"])
    try:
        result = run_shape_validation(args.target, file_path)
    except Exception as exc:
        return fail("schema-check", [f"文件不是合法 UTF-8 JSON：{args.file}: {exc}"])
    return dump(result, 1 if result["errors"] else 0)


def collect_manifest_summary(manifest: dict[str, Any]) -> dict[str, Any]:
    modules = manifest.get("modules") or []
    pages = sum(len(module.get("pages") or []) for module in modules)
    actions = sum(len(page.get("actions") or []) for module in modules for page in (module.get("pages") or []))
    return {"module_count": len(modules), "page_count": pages, "action_count": actions, "module_names": [module.get("module_name", "") for module in modules]}


def run_trace_check(status_path: Path) -> dict[str, Any]:
    status = load_json(status_path)
    project_root = status_path.parent.parent
    manifest_rel = str(status.get("anchors_state", {}).get("meta", {}).get("anchor_manifest", "")).strip()
    if not manifest_rel:
        return {"tool": "trace-check", "result": "fail", "errors": ["anchors_state.meta.anchor_manifest 缺失"], "warnings": [], "checked": ["status-json-readable"]}
    manifest_path = resolve_path(manifest_rel) if Path(manifest_rel).is_absolute() else (project_root / manifest_rel).resolve()
    if not manifest_path.exists():
        return {"tool": "trace-check", "result": "fail", "errors": [f"manifest 路径不存在：{manifest_rel}"], "warnings": [], "checked": ["status-json-readable"]}
    manifest = load_json(manifest_path)
    errors, warnings = validate_manifest_shape(manifest)
    checked = ["status-json-readable", "manifest-json-readable", "manifest-anchor-structure"]
    prd_paths = [status.get("baselines", {}).get("prd", ""), status.get("artifacts", {}).get("prd", "")]
    prototype_paths = [status.get("baselines", {}).get("prototype", "")] + list(status.get("artifacts", {}).get("prototypes", []))
    prd_paths = [item for item in dict.fromkeys(prd_paths) if item]
    prototype_paths = [item for item in dict.fromkeys(prototype_paths) if item]
    for rel in prd_paths:
        if not (project_root / rel).resolve().exists():
            errors.append(f"PRD 路径不存在：{rel}")
    checked.append("prd-paths")
    for rel in prototype_paths:
        if not (project_root / rel).resolve().exists():
            errors.append(f"原型路径不存在：{rel}")
    checked.append("prototype-paths")
    output_dir = project_root / "output"
    if output_dir.exists():
        for file_path in output_dir.rglob("*"):
            if not file_path.is_file():
                continue
            try:
                for index, line in enumerate(read_text(file_path).splitlines(), start=1):
                    if OUTPUT_LEAK_PATTERN.search(line):
                        errors.append(f"人读产物泄漏机读字段：{file_path.relative_to(project_root)}:{index}")
            except UnicodeDecodeError:
                continue
    checked.append("output-machine-field-leak")
    manifest_markers = {
        str(action.get("prototype_locator", {}).get("marker", "")).strip()
        for module in manifest.get("modules") or []
        for page in module.get("pages") or []
        for action in page.get("actions") or []
        if str(action.get("prototype_locator", {}).get("marker", "")).strip()
    }
    html_markers: set[str] = set()
    for rel in prototype_paths:
        if not rel.lower().endswith(".html"):
            continue
        file_path = (project_root / rel).resolve()
        if not file_path.exists():
            continue
        for match in HTML_MARKER_PATTERN.finditer(read_text(file_path)):
            marker = match.group(1) or match.group(2)
            if marker:
                html_markers.add(marker)
    for marker in sorted(manifest_markers):
        if marker not in html_markers:
            warnings.append(f"manifest 中的原型标注未在 HTML 中找到：{marker}")
    checked.append("prototype-marker-mapping")
    summary = collect_manifest_summary(manifest)
    summary["prototype_markers"] = len(manifest_markers)
    return {"tool": "trace-check", "result": "fail" if errors else "warn" if warnings else "pass", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}


def trace_check(args: argparse.Namespace) -> int:
    status_path = resolve_path(args.status_path)
    if not status_path.exists():
        return fail("trace-check", [f"状态文件不存在：{args.status_path}"])
    result = run_trace_check(status_path)
    return dump(result, 1 if result["errors"] else 0)


def build_review_pack(args: argparse.Namespace) -> int:
    status_path = resolve_path(args.status_path)
    output_path = resolve_path(args.output_path)
    status = load_json(status_path)
    project_root = status_path.parent.parent
    manifest_rel = str(status.get("anchors_state", {}).get("meta", {}).get("anchor_manifest", "")).strip()
    manifest_summary: dict[str, Any] = {}
    if manifest_rel:
        manifest_path = resolve_path(manifest_rel) if Path(manifest_rel).is_absolute() else (project_root / manifest_rel).resolve()
        if manifest_path.exists():
            manifest_summary = collect_manifest_summary(load_json(manifest_path))
    schema_status = run_shape_validation("status", status_path)
    schema_manifest_result = {"result": "missing", "errors": [], "warnings": []}
    if manifest_rel:
        manifest_path = resolve_path(manifest_rel) if Path(manifest_rel).is_absolute() else (project_root / manifest_rel).resolve()
        if manifest_path.exists():
            schema_manifest_result = run_shape_validation("manifest", manifest_path)
    trace_payload = run_trace_check(status_path)
    pack = {
        "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "status_summary": {
            "current_stage": status.get("current_stage", ""),
            "current_mode": status.get("current_mode", ""),
            "current_version": status.get("current_version", ""),
            "next_recommended": status.get("next_recommended", ""),
            "blockers": status.get("blockers", []),
            "pending_confirmations": status.get("pending_confirmations", []),
        },
        "baselines": status.get("baselines", {}),
        "traceability": {"anchor_manifest": manifest_rel, "manifest_summary": manifest_summary},
        "artifacts": {
            "prototypes": status.get("artifacts", {}).get("prototypes", []),
            "prd": status.get("artifacts", {}).get("prd", ""),
            "review_records": status.get("artifacts", {}).get("review_records", []),
        },
        "lint_results": {"status_schema": schema_status["result"], "manifest_schema": schema_manifest_result["result"], "trace_check": trace_payload["result"]},
        "review_inputs": {"use_this_pack_only": True, "instruction": "评审时基于本冷启动包、PRD、原型和 manifest 重新判断，不沿用 writer 长上下文惯性。"},
    }
    review_errors, review_warnings = validate_review_pack_shape(pack)
    if review_errors:
        return fail("build-review-pack", review_errors, review_warnings)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(pack, ensure_ascii=False, indent=2), encoding="utf-8-sig")
    return dump({"tool": "build-review-pack", "result": "pass", "output_path": str(output_path), "trace_check": trace_payload["result"]})


def encoding_check(args: argparse.Namespace) -> int:
    root = resolve_path(args.root)
    targets = [root / ".ohmypm", root / "output"]
    errors: list[str] = []
    checked: list[str] = []
    for target in targets:
        if not target.exists():
            continue
        for file_path in target.rglob("*"):
            if not file_path.is_file() or file_path.suffix.lower() not in {".md", ".json", ".html"}:
                continue
            checked.append(str(file_path.relative_to(root)))
            try:
                read_text(file_path)
            except UnicodeDecodeError:
                errors.append(f"非 UTF-8 文件：{file_path.relative_to(root)}")
    result = "fail" if errors else "pass"
    return dump({"tool": "encoding", "result": result, "errors": errors, "warnings": [], "checked": checked}, 1 if errors else 0)


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    schema_parser = subparsers.add_parser("schema-check")
    schema_parser.add_argument("--target", required=True, choices=["status", "manifest", "review-pack"])
    schema_parser.add_argument("--file", required=True)
    trace_parser = subparsers.add_parser("trace-check")
    trace_parser.add_argument("--status-path", required=True)
    review_parser = subparsers.add_parser("build-review-pack")
    review_parser.add_argument("--status-path", required=True)
    review_parser.add_argument("--output-path", required=True)
    encoding_parser = subparsers.add_parser("encoding")
    encoding_parser.add_argument("--root", required=True)
    args = parser.parse_args()
    if args.command == "schema-check":
        return schema_check(args)
    if args.command == "trace-check":
        return trace_check(args)
    if args.command == "build-review-pack":
        return build_review_pack(args)
    return encoding_check(args)


if __name__ == "__main__":
    raise SystemExit(main())
