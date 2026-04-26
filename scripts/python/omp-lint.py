from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_LEAK_PATTERN = re.compile(r"M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref|data-anchor")
HTML_MARKER_PATTERN = re.compile(r'data-anno=["\']([^"\']+)["\']|showAnno\(["\']([^"\']+)["\']')
MANIFEST_SCHEMA_PATH = "contracts/schemas/solution.manifest.schema.json"
REVIEW_PACK_SCHEMA_PATH = "contracts/schemas/review-pack.schema.json"
STATUS_SCHEMA_PATH = "contracts/schemas/status.schema.json"
SCHEMA_MAP = {"status": STATUS_SCHEMA_PATH, "manifest": MANIFEST_SCHEMA_PATH, "review-pack": REVIEW_PACK_SCHEMA_PATH}

def resolve_path(raw: str) -> Path:
    path = Path(raw)
    return path if path.is_absolute() else (Path.cwd() / path).resolve()

def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")

def load_json(path: Path) -> Any:
    return json.loads(read_text(path))

def normalize_marker(value: str) -> str:
    marker = value.strip()
    return marker.zfill(2) if marker.isdigit() else marker

def dump(payload: dict[str, Any], exit_code: int = 0) -> int:
    sys.stdout.write(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    return exit_code

def fail(tool: str, errors: list[str], warnings: list[str] | None = None, checked: list[str] | None = None) -> int:
    return dump({"tool": tool, "result": "fail", "errors": errors, "warnings": warnings or [], "checked": checked or []}, 1)

def validate_schema(instance: Any, schema: dict[str, Any], path: str, errors: list[str]) -> None:
    expected_type = schema.get("type")
    if expected_type == "object":
        if not isinstance(instance, dict):
            errors.append(f"{path or '$'} 应为 object")
            return
        for field in schema.get("required", []):
            if field not in instance:
                errors.append(f"{path or '$'} 缺少字段：{field}")
        properties = schema.get("properties", {})
        for key, subschema in properties.items():
            if key in instance:
                next_path = f"{path}.{key}" if path else key
                validate_schema(instance[key], subschema, next_path, errors)
        return
    if expected_type == "array":
        if not isinstance(instance, list):
            errors.append(f"{path or '$'} 应为 array")
            return
        if "minItems" in schema and len(instance) < int(schema["minItems"]):
            errors.append(f"{path or '$'} 最少需要 {schema['minItems']} 项")
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for index, item in enumerate(instance):
                validate_schema(item, item_schema, f"{path}[{index}]" if path else f"[{index}]", errors)
        return
    if expected_type == "string" and not isinstance(instance, str):
        errors.append(f"{path or '$'} 应为 string")
        return
    if expected_type == "boolean" and not isinstance(instance, bool):
        errors.append(f"{path or '$'} 应为 boolean")
        return
    if expected_type == "integer" and not isinstance(instance, int):
        errors.append(f"{path or '$'} 应为 integer")
        return
    if expected_type == "number" and not isinstance(instance, (int, float)):
        errors.append(f"{path or '$'} 应为 number")
        return
    if "enum" in schema and instance not in schema["enum"]:
        errors.append(f"{path or '$'} 枚举非法：{instance}")
    if expected_type == "string" and "pattern" in schema and isinstance(instance, str):
        if not re.match(schema["pattern"], instance):
            errors.append(f"{path or '$'} 不符合格式要求：{instance}")

def load_schema(target: str) -> dict[str, Any]:
    schema_rel = SCHEMA_MAP[target]
    schema_path = resolve_path(schema_rel) if Path(schema_rel).is_absolute() else (REPO_ROOT / schema_rel).resolve()
    return load_json(schema_path)

def run_shape_validation(target: str, file_path: Path) -> dict[str, Any]:
    payload = load_json(file_path)
    schema = load_schema(target)
    errors: list[str] = []
    warnings: list[str] = []
    validate_schema(payload, schema, "", errors)
    return {
        "tool": "schema-check",
        "target": target,
        "schema": SCHEMA_MAP[target],
        "result": "fail" if errors else "warn" if warnings else "pass",
        "errors": errors,
        "warnings": warnings,
        "checked": [str(file_path)],
    }

def validate_payload_against_target(target: str, payload: Any) -> tuple[list[str], list[str]]:
    schema = load_schema(target)
    errors: list[str] = []
    warnings: list[str] = []
    validate_schema(payload, schema, "", errors)
    return errors, warnings


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
    errors, warnings = validate_payload_against_target("manifest", manifest)
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
        normalize_marker(str(action.get("prototype_locator", {}).get("marker", "")))
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
                html_markers.add(normalize_marker(marker))
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
    blocking_errors = []
    if schema_status["result"] == "fail":
        blocking_errors.append("status.json 未通过 schema-check")
    if schema_manifest_result["result"] == "fail":
        blocking_errors.append("solution.manifest.json 未通过 schema-check")
    if trace_payload["result"] == "fail":
        blocking_errors.append("未通过 trace-check，不能生成可用 review-pack")
    if blocking_errors:
        return fail("build-review-pack", blocking_errors)
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
    review_errors, review_warnings = validate_payload_against_target("review-pack", pack)
    if review_errors:
        return fail("build-review-pack", review_errors, review_warnings)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(pack, ensure_ascii=False, indent=2), encoding="utf-8-sig")
    result = "warn" if schema_status["result"] == "warn" or schema_manifest_result["result"] == "warn" or trace_payload["result"] == "warn" else "pass"
    return dump({"tool": "build-review-pack", "result": result, "output_path": str(output_path), "trace_check": trace_payload["result"]})


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
