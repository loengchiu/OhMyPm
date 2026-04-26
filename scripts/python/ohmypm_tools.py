from __future__ import annotations

import argparse
import contextlib
import io
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


SCRIPT_PATH = Path(__file__).resolve()
TOOLS_DIR = SCRIPT_PATH.parents[1] / "tools"
REPO_ROOT = SCRIPT_PATH.parents[2]


class OhMyPmError(Exception):
    pass


def fail(message: str) -> "NoReturn":
    raise OhMyPmError(message)


def read_utf8_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def read_utf8_lines(path: Path) -> list[str]:
    return read_utf8_text(path).splitlines()


def write_utf8_bom_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8-sig", newline="")


def read_utf8_json(path: Path) -> Any:
    return json.loads(read_utf8_text(path))


def write_json(path: Path, payload: Any) -> None:
    write_utf8_bom_text(path, json.dumps(payload, ensure_ascii=False, indent=2))


def json_compact(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, separators=(",", ":"))


def output(payload: Any) -> int:
    sys.stdout.write(json.dumps(payload, ensure_ascii=False, indent=2))
    sys.stdout.write("\n")
    return 0


def has_text(value: Any) -> bool:
    return value is not None and str(value).strip() != ""


def has_items(value: Any) -> bool:
    if value is None:
        return False
    if isinstance(value, list):
        return len(value) > 0
    return len(as_list(value)) > 0


def as_list(value: Any) -> list[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def parse_json_array(raw: Any, field_name: str) -> list[Any]:
    if raw is None or (isinstance(raw, str) and raw.strip() == ""):
        return []
    parsed = raw
    if isinstance(raw, str):
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError as exc:
            fail(f"{field_name} 不是合法 JSON: {exc}")
    return as_list(parsed)


def parse_bool_value(raw: Any, field_name: str) -> bool:
    if raw is None:
        fail(f"{field_name} 不能为空")
    if isinstance(raw, bool):
        return raw
    text = str(raw).strip().lower()
    mapping = {
        "true": True,
        "false": False,
        "1": True,
        "0": False,
        "yes": True,
        "no": False,
    }
    if text not in mapping:
        fail(f"{field_name} 不是合法布尔值")
    return mapping[text]


def parse_optional_bool(raw: Any, field_name: str) -> bool | None:
    if raw is None or (isinstance(raw, str) and raw.strip() == ""):
        return None
    return parse_bool_value(raw, field_name)


def ensure_one_of(value: Any, allowed: list[str], field_name: str, *, allow_blank: bool = False) -> None:
    if not has_text(value):
        if allow_blank:
            return
        fail(f"{field_name} 不能为空")
    if str(value) not in allowed:
        fail(f"{field_name} 可选值应为：{', '.join(allowed)}")


def resolve_status_path(raw: str) -> Path:
    path = Path(raw)
    if not path.is_absolute():
        path = Path.cwd() / path
    return path.resolve()


def get_project_root_from_status(status_path: Path) -> Path:
    if status_path.parent.name == ".ohmypm":
        return status_path.parent.parent
    return Path.cwd().resolve()


def resolve_project_path(project_root: Path, raw_path: str) -> Path:
    path = Path(raw_path)
    if path.is_absolute():
        return path
    return (project_root / path).resolve()


def ensure_status_shape(status: dict[str, Any]) -> None:
    status.setdefault("baselines", {})
    status["baselines"].setdefault("solution", "")
    status["baselines"].setdefault("response_plan", "")
    status["baselines"].setdefault("prototype", "")
    status["baselines"].setdefault("prd", "")
    status.setdefault("artifacts", {})
    status["artifacts"].setdefault("solution_notes", [])
    status["artifacts"].setdefault("response_notes", [])
    status["artifacts"].setdefault("prototypes", [])
    status["artifacts"].setdefault("prd", "")
    status["artifacts"].setdefault("review_records", [])
    status["artifacts"].setdefault("fix_records", [])
    status["artifacts"].setdefault("change_records", [])
    status.setdefault("anchors_state", {})
    status["anchors_state"].setdefault("meta", {})
    status["anchors_state"]["meta"].setdefault("anchor_manifest", "")
    status.setdefault("review_state", {})
    status["review_state"].setdefault("must_fix_before_next_stage", [])
    status["review_state"].setdefault("last_review_result", "")
    status.setdefault("memory_refs", {})
    status["memory_refs"].setdefault("system_memory_cards", [])
    status.setdefault("alignment_state", {})
    status.setdefault("fallback_state", {})
    status.setdefault("change_state", {})
    status.setdefault("overwrite_queue", [])
    status.setdefault("blockers", [])
    status.setdefault("pending_confirmations", [])


def load_status(path_value: str) -> tuple[Path, Path, dict[str, Any]]:
    status_path = resolve_status_path(path_value)
    if not status_path.exists():
        fail(f"状态文件不存在：{path_value}")
    try:
        status = read_utf8_json(status_path)
    except json.JSONDecodeError as exc:
        fail(f"状态文件不是合法 UTF-8 JSON：{path_value}: {exc}")
    ensure_status_shape(status)
    project_root = get_project_root_from_status(status_path)
    return status_path, project_root, status


def invoke_local_tool(tool_name: str, params: dict[str, Any]) -> tuple[int, str, Any | None]:
    command = [sys.executable, str(SCRIPT_PATH), tool_name, "--params-json", json.dumps(params, ensure_ascii=False)]
    completed = subprocess.run(command, capture_output=True, text=False)
    stdout_text = completed.stdout.decode("utf-8", errors="replace") if completed.stdout else ""
    stderr_text = completed.stderr.decode("utf-8", errors="replace") if completed.stderr else ""
    raw = (stdout_text or stderr_text).strip()
    parsed = None
    if raw:
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = None
    return completed.returncode, raw, parsed


def invoke_internal_tool(tool_name: str, params: dict[str, Any]) -> tuple[int, str, Any | None]:
    stdout_buffer = io.StringIO()
    stderr_buffer = io.StringIO()
    exit_code = 0
    try:
        with contextlib.redirect_stdout(stdout_buffer), contextlib.redirect_stderr(stderr_buffer):
            exit_code = TOOL_MAP[tool_name](params)
    except OhMyPmError as exc:
        stderr_buffer.write(f"[OhMyPm] {exc}\n")
        exit_code = 1
    except json.JSONDecodeError as exc:
        stderr_buffer.write(f"[OhMyPm] JSON 解析失败: {exc}\n")
        exit_code = 1
    raw = (stdout_buffer.getvalue() or stderr_buffer.getvalue()).strip()
    parsed = None
    if raw:
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = None
    return exit_code, raw, parsed


def update_status(status: dict[str, Any], status_path: Path, params: dict[str, Any]) -> None:
    ensure_status_shape(status)
    round_result_enums = ["continue_alignment", "need_materials", "need_internal_repair", "ready_for_preflight"]
    fallback_enums = ["internal_repair", "need_materials", "reopen_alignment"]
    change_enums = ["minor_patch", "within_module", "new_module", "structural_change"]

    if "Stage" in params:
        status["current_stage"] = params["Stage"]
    if "Mode" in params:
        status["current_mode"] = params["Mode"]
    if "Version" in params:
        status["current_version"] = params["Version"]
    if "LastAction" in params:
        status["last_action"] = params["LastAction"]
    if "NextRecommended" in params:
        status["next_recommended"] = params["NextRecommended"]
    if "ContextSummary" in params:
        status["context_summary"] = params["ContextSummary"]

    if "ContextPackageJson" in params:
        raw = params["ContextPackageJson"]
        if not has_text(raw):
            fail("ContextPackageJson 不能为空")
        status["context_package"] = json.loads(raw)

    if "AnchorsStateJson" in params:
        raw = params["AnchorsStateJson"]
        if not has_text(raw):
            fail("AnchorsStateJson 不能为空")
        status["anchors_state"] = json.loads(raw)

    if "BaselineField" in params:
        baseline_field = params["BaselineField"]
        if "BaselinePath" not in params:
            fail("传入 BaselineField 时必须同时传入 BaselinePath")
        if baseline_field not in status["baselines"]:
            fail(f"不支持的 baseline 字段：{baseline_field}")
        baseline_path = resolve_project_path(get_project_root_from_status(status_path), str(params["BaselinePath"]))
        if not baseline_path.exists():
            fail(f"baseline 路径不存在：{params['BaselinePath']}")
        status["baselines"][baseline_field] = str(params["BaselinePath"])

    if "ArtifactField" in params:
        artifact_field = params["ArtifactField"]
        if "ArtifactPath" not in params:
            fail("传入 ArtifactField 时必须同时传入 ArtifactPath")
        if artifact_field not in status["artifacts"]:
            fail(f"不支持的 artifact 字段：{artifact_field}")
        current_value = status["artifacts"][artifact_field]
        if isinstance(current_value, list):
            items = [item for item in current_value if item]
            items.append(params["ArtifactPath"])
            unique_items: list[str] = []
            for item in items:
                if item not in unique_items:
                    unique_items.append(item)
            status["artifacts"][artifact_field] = unique_items
        else:
            status["artifacts"][artifact_field] = params["ArtifactPath"]

    if "BlockersJson" in params:
        status["blockers"] = parse_json_array(params["BlockersJson"], "blockers")

    if "PendingConfirmationsJson" in params:
        status["pending_confirmations"] = parse_json_array(params["PendingConfirmationsJson"], "pending_confirmations")

    if "ReviewResult" in params:
        status["review_state"]["last_review_result"] = params["ReviewResult"]

    if "ReviewMustFixJson" in params:
        status["review_state"]["must_fix_before_next_stage"] = parse_json_array(
            params["ReviewMustFixJson"], "review_state.must_fix_before_next_stage"
        )

    if "OverwriteQueueJson" in params:
        status["overwrite_queue"] = parse_json_array(params["OverwriteQueueJson"], "overwrite_queue")

    if "SystemMemoryCardsJson" in params:
        status["memory_refs"]["system_memory_cards"] = parse_json_array(
            params["SystemMemoryCardsJson"], "memory_refs.system_memory_cards"
        )

    if "RoundNumber" in params:
        status["alignment_state"]["round_number"] = int(params["RoundNumber"])
    if "RoundGoal" in params:
        status["alignment_state"]["round_goal"] = params["RoundGoal"]
    if "RoundInputsJson" in params:
        status["alignment_state"]["round_inputs"] = parse_json_array(
            params["RoundInputsJson"], "alignment_state.round_inputs"
        )
    if "CurrentOutput" in params:
        status["alignment_state"]["current_output"] = params["CurrentOutput"]
    if "RoundResult" in params:
        ensure_one_of(params["RoundResult"], round_result_enums, "RoundResult")
        status["alignment_state"]["round_result"] = params["RoundResult"]
    if "LoopHistorySummary" in params:
        status["alignment_state"]["history_summary"] = params["LoopHistorySummary"]

    if "FallbackType" in params:
        ensure_one_of(params["FallbackType"], fallback_enums, "FallbackType")
        status["fallback_state"]["fallback_type"] = params["FallbackType"]
    if "FallbackReason" in params:
        status["fallback_state"]["fallback_reason"] = params["FallbackReason"]

    if "ChangeCategory" in params:
        ensure_one_of(params["ChangeCategory"], change_enums, "ChangeCategory")
        status["change_state"]["change_category"] = params["ChangeCategory"]
    if "ChangeCategoryConfirmedByPm" in params:
        status["change_state"]["change_category_confirmed_by_pm"] = parse_bool_value(
            params["ChangeCategoryConfirmedByPm"], "ChangeCategoryConfirmedByPm"
        )

    if (
        ("FallbackType" in params or "RoundResult" in params)
        and status["fallback_state"].get("fallback_type") == "reopen_alignment"
        and status["alignment_state"].get("round_result") == "ready_for_preflight"
    ):
        fail("FallbackType=reopen_alignment 不能与 RoundResult=ready_for_preflight 同时存在")

    heavy_change = status["change_state"].get("change_category") in {"new_module", "structural_change"}
    change_decision_stage = status.get("current_stage") in {"omp-change", "omp-disc"}
    if ("ChangeCategory" in params or "ChangeCategoryConfirmedByPm" in params) and heavy_change:
        if not status["change_state"].get("change_category_confirmed_by_pm") and not change_decision_stage:
            fail("重变更在离开 omp-change / omp-disc 前必须确认 ChangeCategoryConfirmedByPm")

    write_json(status_path, status)


def cmd_status_read(params: dict[str, Any]) -> int:
    path = Path(params.get("Path", ".ohmypm/status.json"))
    status_path = resolve_status_path(str(path))
    if not status_path.exists():
        fail("状态文件不存在：.ohmypm/status.json")
    sys.stdout.write(read_utf8_text(status_path))
    if not read_utf8_text(status_path).endswith("\n"):
        sys.stdout.write("\n")
    return 0


def cmd_status_write(params: dict[str, Any]) -> int:
    status_path, _, status = load_status(str(params.get("Path", ".ohmypm/status.json")))
    update_status(status, status_path, params)
    print("[OhMyPm] 状态文件已更新。")
    return 0


def cmd_artifact_sync(params: dict[str, Any]) -> int:
    forwarded = dict(params)
    forwarded.setdefault("Path", ".ohmypm/status.json")
    return cmd_status_write(forwarded)


def cmd_status_apply(params: dict[str, Any]) -> int:
    payload_path = resolve_project_path(Path.cwd(), str(params["PayloadPath"]))
    if not payload_path.exists():
        fail(f"状态载荷文件不存在：{params['PayloadPath']}")
    payload = read_utf8_json(payload_path)
    return cmd_artifact_sync(payload)


def find_memory_section(lines: list[str], section_title: str | None, section_number: int | None) -> tuple[int, int]:
    number_pattern = re.compile(r"^##\s+(\d+)\.\s+(.+)$")
    start_index = -1
    end_index = len(lines)
    for index, line in enumerate(lines):
        match = number_pattern.match(line)
        if not match:
            continue
        matched_number = int(match.group(1))
        matched_title = match.group(2).strip()
        target_matched = False
        if section_number and matched_number == section_number:
            target_matched = True
        elif section_title and matched_title == section_title:
            target_matched = True
        if target_matched:
            start_index = index
            continue
        if start_index >= 0:
            end_index = index
            break
    if start_index < 0:
        if section_number:
            fail(f"项目记忆章节不存在：{section_number}")
        fail(f"项目记忆章节不存在：{section_title}")
    return start_index, end_index


def apply_section_update(lines: list[str], update: dict[str, Any]) -> list[str]:
    start_index, end_index = find_memory_section(
        lines,
        update.get("SectionTitle"),
        int(update["SectionNumber"]) if update.get("SectionNumber") else None,
    )
    after = lines[end_index:]
    content_lines = str(update["Content"]).splitlines()
    replace_whole_section = False
    for line in content_lines:
        if not line.strip():
            continue
        replace_whole_section = line.startswith("## ")
        break
    before = lines[:start_index] if replace_whole_section else lines[: start_index + 1]
    updated = before + content_lines + [""] + after
    return updated


def cmd_memory_write(params: dict[str, Any]) -> int:
    memory_path = resolve_project_path(Path.cwd(), str(params.get("Path", ".ohmypm/memory.md")))
    if not memory_path.exists():
        fail("项目记忆文件不存在：.ohmypm/memory.md")
    lines = read_utf8_lines(memory_path)
    update = {
        "SectionTitle": params.get("SectionTitle"),
        "SectionNumber": params.get("SectionNumber"),
        "Content": params["Content"],
    }
    updated = apply_section_update(lines, update)
    write_utf8_bom_text(memory_path, "\r\n".join(updated))
    print("[OhMyPm] 项目记忆已更新。")
    return 0


def cmd_memory_apply(params: dict[str, Any]) -> int:
    payload_path = resolve_project_path(Path.cwd(), str(params["PayloadPath"]))
    memory_path = resolve_project_path(Path.cwd(), str(params.get("Path", ".ohmypm/memory.md")))
    if not payload_path.exists():
        fail(f"项目记忆更新载荷不存在：{params['PayloadPath']}")
    if not memory_path.exists():
        fail("项目记忆文件不存在：.ohmypm/memory.md")
    payload = read_utf8_json(payload_path)
    updates = payload.get("updates")
    if not updates:
        fail("缺少字段：updates")
    lines = read_utf8_lines(memory_path)
    for update in as_list(updates):
        if "Content" not in update:
            fail("缺少字段：Content")
        lines = apply_section_update(lines, update)
    write_utf8_bom_text(memory_path, "\r\n".join(lines))
    print("[OhMyPm] 项目记忆已批量更新。")
    return 0


def cmd_ask_back_apply(params: dict[str, Any]) -> int:
    status_path, _, status = load_status(str(params.get("Path", ".ohmypm/status.json")))
    if "PendingConfirmationsJson" in params:
        status["pending_confirmations"] = parse_json_array(params["PendingConfirmationsJson"], "pending_confirmations_json")
    elif has_text(params.get("AnsweredConfirmation")):
        answered = str(params["AnsweredConfirmation"])
        status["pending_confirmations"] = [item for item in as_list(status.get("pending_confirmations")) if item != answered]
    parsed_pm_confirmation = parse_optional_bool(params.get("ChangeCategoryConfirmedByPm"), "ChangeCategoryConfirmedByPm")
    if parsed_pm_confirmation is not None:
        status["change_state"]["change_category_confirmed_by_pm"] = parsed_pm_confirmation
    status["last_action"] = params.get("LastAction", "ask_back_apply")
    status["next_recommended"] = params.get(
        "NextRecommended", "下一步：回到刚才被卡住的阶段，并按最新确认结果重新判断是否可以推进。"
    )
    if "ContextSummary" in params:
        status["context_summary"] = params["ContextSummary"]
    write_json(status_path, status)
    print("[OhMyPm] ask-back 已回写状态。")
    return 0


def get_bool_value(value: Any) -> bool:
    if value is None:
        return False
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() in {"true", "1", "yes"}


def new_trigger(code: str, category: str, source: str, impacts: list[str], question: str, handling: str) -> dict[str, Any]:
    return {
        "trigger_code": code,
        "question_category": category,
        "source": source,
        "impacts": impacts,
        "minimal_question": question,
        "handling": handling,
    }


def cmd_ask_back_plan(params: dict[str, Any]) -> int:
    _, _, status = load_status(str(params.get("Path", ".ohmypm/status.json")))
    triggers: list[dict[str, Any]] = []
    for fact in as_list(status.get("anchors_state", {}).get("meta", {}).get("confirmed_facts")):
        if not has_text(fact):
            continue
        if re.search(r"未确认|待确认|待澄清|open question|pending confirmation", str(fact)):
            triggers.append(
                new_trigger(
                    "unconfirmed_leaked_into_confirmed",
                    "boundary_guard",
                    "anchors_state.meta.confirmed_facts",
                    ["scope_judgement", "delivery_validity"],
                    "当前已确认事实里混入了未确认内容，先做内部修正，把未确认项移回待确认区域后再继续。",
                    "internal_repair",
                )
            )
            break
    meta = status.get("anchors_state", {}).get("meta", {})
    if has_items(meta.get("open_questions")) and get_bool_value(meta.get("can_progress")):
        triggers.append(
            new_trigger(
                "open_question_progress_conflict",
                "boundary_guard",
                "anchors_state.meta.open_questions",
                ["gate_validity", "delivery_validity"],
                "当前未确认项仍会影响推进，但状态被写成可推进，先做内部修正，重新判定 can_progress 后再继续。",
                "internal_repair",
            )
        )
    anchors = status.get("anchors_state", {}).get("anchors", {})
    artifact_contract = status.get("anchors_state", {}).get("artifact_contract", {})
    expected_refs: list[str] = []
    for module in as_list(anchors.get("modules")):
        for page in as_list(module.get("pages")):
            for flow in as_list(page.get("flows")):
                for action in as_list(flow.get("actions")):
                    for rule_ref in as_list(action.get("rules_ref")):
                        for proto_ref in as_list(action.get("prototype_ref")):
                            if has_text(rule_ref) and has_text(proto_ref):
                                expected_refs.append(f"{str(proto_ref).strip()} <-> {str(rule_ref).strip()}")
    expected_refs = list(dict.fromkeys(expected_refs))
    shared_refs = [str(item).strip() for item in as_list(artifact_contract.get("shared_refs")) if has_text(item)]
    if expected_refs:
        mismatch = not shared_refs or any(item not in shared_refs for item in expected_refs)
        if mismatch:
            triggers.append(
                new_trigger(
                    "anchors_state_shared_ref_mismatch",
                    "boundary_guard",
                    "anchors_state.artifact_contract.shared_refs",
                    ["delivery_validity", "review_validity"],
                    "当前原型编号和 PRD 规则引用没有对齐，先做内部修正，补齐 shared_refs 后再继续。",
                    "internal_repair",
                )
            )
    package = status.get("context_package")
    if not package or not has_text(package.get("request_summary")):
        triggers.append(
            new_trigger(
                "missing_request_summary",
                "phase0_context",
                "context_package.request_summary",
                ["reply_quality", "scope_judgement"],
                "这次你想做的事情，能不能先用一句人话说清楚？",
                "ask_pm",
            )
        )
    elif not has_text(package.get("business_stage")):
        triggers.append(
            new_trigger(
                "missing_business_stage",
                "phase0_context",
                "context_package.business_stage",
                ["reply_quality", "module_judgement"],
                "这件事大概发生在哪个业务环节？",
                "ask_pm",
            )
        )
    elif not has_items(package.get("system_or_page_clues")) and not has_items(package.get("material_paths")):
        triggers.append(
            new_trigger(
                "missing_system_clue_and_material",
                "phase0_context",
                "context_package.system_or_page_clues + material_paths",
                ["reply_quality", "alignment_efficiency"],
                "你现在能给到的最直接线索是什么：现有系统或页面，还是一份现成资料？",
                "ask_pm",
            )
        )
    for item in as_list(status.get("pending_confirmations")):
        category = "fact_gap"
        impacts = ["current_understanding"]
        question = f"请确认这个还没定下来的点：{item}"
        if re.search(r"scope boundary", str(item)):
            category = "scope_gap"
            impacts = ["module_list", "estimate", "schedule"]
            question = "这次新增内容是否仍然属于当前版本范围内的补充，而不是需要拆成单独的新范围？"
        triggers.append(new_trigger("pending_confirmation", category, str(item), impacts, question, "ask_pm"))
    change_state = status.get("change_state", {})
    change_confirmed = get_bool_value(change_state.get("change_category_confirmed_by_pm"))
    if has_text(change_state.get("change_category")) and not change_confirmed:
        triggers.append(
            new_trigger(
                "pm_change_confirmation",
                "change_classification",
                str(change_state.get("change_category")),
                ["delivery_scope", "change_path", "baseline_decision"],
                f"当前请求是否最终确认保持 '{change_state.get('change_category')}' 这个分类？",
                "ask_pm",
            )
        )
    fallback_state = status.get("fallback_state", {})
    if has_text(fallback_state.get("fallback_type")) and fallback_state.get("fallback_type") not in {"internal_repair", "need_materials"}:
        triggers.append(
            new_trigger(
                "fallback_requires_pm_alignment",
                "alignment_decision",
                str(fallback_state.get("fallback_type")),
                ["next_stage", "round_progression"],
                "在继续更重动作之前，是否需要重新开一轮对齐？",
                "ask_pm",
            )
        )
    ask_pm = [item for item in triggers if item["handling"] == "ask_pm"]
    internal_only = [item for item in triggers if item["handling"] == "internal_repair"]
    next_recommended = "当前没有需要抛给 PM 的追问"
    if ask_pm:
        next_recommended = "进入 ask-back，等待 PM 回答唯一问题"
    elif internal_only:
        next_recommended = "当前存在内部矛盾或引用失配，先做内部修正，不要把这个问题抛给 PM。"
    return output(
        {
            "current_stage": status.get("current_stage"),
            "current_mode": status.get("current_mode"),
            "ask_back_required": len(ask_pm) > 0,
            "internal_placeholder_required": len(internal_only) > 0,
            "trigger_count": len(triggers),
            "triggers": triggers,
            "next_recommended": next_recommended,
        }
    )


def has_minimal_context_package(status: dict[str, Any]) -> bool:
    package = status.get("context_package")
    if not isinstance(package, dict):
        return False
    return (
        has_text(package.get("request_summary"))
        and has_text(package.get("business_stage"))
        and "system_or_page_clues" in package
        and "material_paths" in package
        and "context_gaps" in package
    )


def cmd_state_machine(params: dict[str, Any]) -> int:
    _, _, status = load_status(str(params.get("Path", ".ohmypm/status.json")))

    def preferred_skill() -> str:
        if status.get("current_mode") == "change_control" or status.get("current_stage") == "omp-change":
            return "omp-change"
        if has_items(status.get("overwrite_queue")):
            return "omp-fix"
        if has_items(status.get("review_state", {}).get("must_fix_before_next_stage")):
            return "omp-fix"
        if not has_minimal_context_package(status):
            return "omp-disc"
        if has_items(status.get("pending_confirmations")):
            return "omp-disc"
        if has_text(status.get("fallback_state", {}).get("fallback_type")):
            return "omp-disc"
        current_stage = status.get("current_stage")
        if current_stage == "omp-review":
            return "omp-review"
        if current_stage == "omp-proto":
            if not has_text(status.get("baselines", {}).get("prd")):
                return "omp-prd"
            return "omp-review"
        if current_stage == "omp-prd":
            return "omp-review"
        if status.get("alignment_state", {}).get("round_result") == "ready_for_preflight":
            if not has_text(status.get("baselines", {}).get("prototype")):
                return "omp-proto"
            if not has_text(status.get("baselines", {}).get("prd")):
                return "omp-prd"
            return "omp-review"
        if status.get("current_mode") == "alignment_loop":
            if int(status.get("alignment_state", {}).get("round_number", 0)) >= 1:
                return "omp-solution"
            return "omp-disc"
        if current_stage in {"omp-listen", "omp-disc"}:
            return "omp-disc"
        if current_stage in {"omp-reply", "omp-align", "omp-solution"}:
            return "omp-solution"
        return "omp-disc"

    return output(
        {
            "current_mode": status.get("current_mode"),
            "current_stage": status.get("current_stage"),
            "preferred_skill": preferred_skill(),
            "blocked_by": as_list(status.get("blockers")),
            "pending_confirmations": as_list(status.get("pending_confirmations")),
            "review_must_fix": as_list(status.get("review_state", {}).get("must_fix_before_next_stage")),
            "fallback_type": status.get("fallback_state", {}).get("fallback_type"),
            "round_result": status.get("alignment_state", {}).get("round_result"),
        }
    )


def get_action_name(skill: str) -> str:
    return {
        "omp-disc": "调研",
        "omp-solution": "方案",
        "omp-proto": "做原型",
        "omp-prd": "写 PRD",
        "omp-review": "评审",
        "omp-change": "改需求",
        "omp-fix": "修问题",
    }.get(skill, skill)


def get_gate_name(skill: str) -> str:
    return {
        "omp-disc": "omp-disc",
        "omp-solution": "omp-solution",
        "omp-proto": "omp-deliver",
        "omp-prd": "omp-deliver",
        "omp-change": "omp-change",
    }.get(skill, "")


def get_required_contracts(skill: str) -> list[str]:
    return {
        "omp-disc": ["contracts/context-package.md"],
        "omp-solution": ["contracts/traceability.md"],
        "omp-proto": ["contracts/delivery.md", "contracts/traceability.md"],
        "omp-prd": ["contracts/delivery.md", "contracts/anchors.md", "contracts/traceability.md"],
        "omp-review": ["contracts/review.md", "contracts/traceability.md"],
        "omp-change": ["contracts/gates.md"],
        "omp-fix": ["contracts/overwrite.md"],
    }.get(skill, [])


def resolve_explicit_skill(intent_text: str, preferred_skill: str) -> str:
    text = intent_text.strip().lower()
    if not text:
        return preferred_skill
    if re.search(r"评审|review", text):
        return "omp-review"
    if re.search(r"改需求|需求变更|变更分类|变更处理|change", text):
        return "omp-change"
    if re.search(r"修问题|修正|修复|修复问题|处理问题|fix", text):
        return "omp-fix"
    if re.search(r"做原型|原型|proto|prototype", text):
        return "omp-proto"
    if re.search(r"写\s*prd|\bprd\b", text):
        return "omp-prd"
    if re.search(r"开工检查|预检|preflight|检查能不能进正式交付", text):
        return preferred_skill
    if re.search(r"方案稿|方案|solution|sol", text):
        return "omp-solution"
    if re.search(r"调研稿|调研|访谈|澄清|discovery|disc", text):
        return "omp-disc"
    if re.search(r"推进检查|追问|ask-back|确认的点|唯一问题", text):
        return "omp-disc"
    if re.search(r"需求|先看|先帮我|新需求|原始材料|资料", text):
        return "omp-disc"
    if re.search(r"继续|下一步|继续吧|往下走", text):
        return preferred_skill
    return preferred_skill


def cmd_route_resolve(params: dict[str, Any]) -> int:
    status_path = str(params.get("StatusPath", ".ohmypm/status.json"))
    status_code, raw, parsed = invoke_internal_tool("state-machine", {"Path": status_path})
    if status_code != 0 or not isinstance(parsed, dict):
        fail(f"状态文件不存在：{status_path}" if not raw else raw)
    preferred_skill = parsed["preferred_skill"]
    force_skill = str(params.get("ForceSkill", "") or "")
    skill = force_skill if force_skill.strip() else resolve_explicit_skill(str(params.get("IntentText", "")), preferred_skill)
    return output(
        {
            "current_stage": parsed.get("current_stage"),
            "current_mode": parsed.get("current_mode"),
            "skill": skill,
            "skill_path": f"skills/{skill}/SKILL.md",
            "action_name": get_action_name(skill),
            "gate_name": get_gate_name(skill),
            "required_contracts": get_required_contracts(skill),
        }
    )


def has_anchors_state_meta(status: dict[str, Any]) -> bool:
    meta = status.get("anchors_state", {}).get("meta", {})
    return has_text(meta.get("version")) and has_text(meta.get("scope_summary")) and has_text(meta.get("business_goal"))


def has_solution_baseline(status: dict[str, Any]) -> bool:
    return has_text(status.get("baselines", {}).get("solution"))


def has_solution_notes(status: dict[str, Any]) -> bool:
    return has_items(status.get("artifacts", {}).get("solution_notes"))


def has_anchor_manifest(status: dict[str, Any]) -> bool:
    return has_text(status.get("anchors_state", {}).get("meta", {}).get("anchor_manifest"))


def has_module_anchors(status: dict[str, Any]) -> bool:
    return has_items(status.get("anchors_state", {}).get("anchors", {}).get("modules"))


def has_page_or_flow_anchors(status: dict[str, Any]) -> bool:
    for module in as_list(status.get("anchors_state", {}).get("anchors", {}).get("modules")):
        for page in as_list(module.get("pages")):
            if has_text(page.get("page_name")) or has_items(page.get("flows")):
                return True
    return False


def get_anchor_action_refs(status: dict[str, Any]) -> list[str]:
    refs: list[str] = []
    for module in as_list(status.get("anchors_state", {}).get("anchors", {}).get("modules")):
        for page in as_list(module.get("pages")):
            for flow in as_list(page.get("flows")):
                for action in as_list(flow.get("actions")):
                    for rule_ref in as_list(action.get("rules_ref")):
                        for proto_ref in as_list(action.get("prototype_ref")):
                            if has_text(rule_ref) and has_text(proto_ref):
                                refs.append(f"{str(proto_ref).strip()} <-> {str(rule_ref).strip()}")
    return list(dict.fromkeys(refs))


def has_anchors_state_reference_mismatch(status: dict[str, Any]) -> bool:
    artifact_contract = status.get("anchors_state", {}).get("artifact_contract", {})
    expected = get_anchor_action_refs(status)
    shared = [str(item).strip() for item in as_list(artifact_contract.get("shared_refs")) if has_text(item)]
    if not expected:
        return False
    if not shared:
        return True
    return any(item not in shared for item in expected)


def has_confirmed_facts_boundary_leak(status: dict[str, Any]) -> bool:
    for fact in as_list(status.get("anchors_state", {}).get("meta", {}).get("confirmed_facts")):
        if has_text(fact) and re.search(r"未确认|待确认|待澄清|open question|open_questions|pending confirmation", str(fact).strip()):
            return True
    return False


def has_open_question_progress_conflict(status: dict[str, Any]) -> bool:
    meta = status.get("anchors_state", {}).get("meta", {})
    return has_items(meta.get("open_questions")) and bool(meta.get("can_progress"))


def can_progress_by_anchors_state(status: dict[str, Any]) -> bool:
    return bool(status.get("anchors_state", {}).get("meta", {}).get("can_progress"))


def add_enum_error(errors: list[str], field_name: str, value: Any, allowed: list[str]) -> None:
    errors.append(f"{field_name} 可选值应为：{', '.join(allowed)}；当前值：{value}")


def add_ask_back_error(errors: list[str], reason: str, question: str) -> None:
    errors.append(f"需要追问：{reason} | 最小问题：{question}")


def cmd_stage_gate(params: dict[str, Any]) -> int:
    gate = str(params["Gate"])
    _, _, status = load_status(str(params.get("Path", ".ohmypm/status.json")))
    errors: list[str] = []
    round_result_enums = ["continue_alignment", "need_materials", "need_internal_repair", "ready_for_preflight"]
    fallback_enums = ["internal_repair", "need_materials", "reopen_alignment"]
    change_enums = ["minor_patch", "within_module", "new_module", "structural_change"]

    if has_items(status.get("blockers")):
        errors.append("blockers 不为空")
    if has_confirmed_facts_boundary_leak(status):
        errors.append("confirmed_facts 混入了未确认内容")
    if has_open_question_progress_conflict(status):
        errors.append("open_questions 未清空但 can_progress=true")

    if gate == "omp-disc":
        if not has_minimal_context_package(status):
            errors.append("context_package 不完整")
        if not has_text(status.get("current_version")):
            errors.append("current_version 为空")
        if not has_anchors_state_meta(status):
            errors.append("anchors_state.meta 不完整")
        if not (has_text(status.get("baselines", {}).get("response_plan")) or has_items(status.get("artifacts", {}).get("response_notes"))):
            errors.append("缺少调研基线或调研记录")
        if not has_text(status.get("context_summary")):
            errors.append("context_summary 为空")
    elif gate == "omp-solution":
        if not has_minimal_context_package(status):
            errors.append("context_package 不完整")
        if not has_anchors_state_meta(status):
            errors.append("anchors_state.meta 不完整")
        if not has_module_anchors(status):
            errors.append("anchors_state.anchors.modules 为空")
        if int(status.get("alignment_state", {}).get("round_number", 0)) < 1:
            errors.append("alignment_state.round_number 必须 >= 1")
        if not has_text(status.get("alignment_state", {}).get("round_goal")):
            errors.append("alignment_state.round_goal 为空")
        if not has_items(status.get("alignment_state", {}).get("round_inputs")):
            errors.append("alignment_state.round_inputs 为空")
        if not has_text(status.get("alignment_state", {}).get("current_output")):
            errors.append("alignment_state.current_output 为空")
        if not has_text(status.get("alignment_state", {}).get("history_summary")):
            errors.append("alignment_state.history_summary 为空")
        if status.get("alignment_state", {}).get("round_result") not in round_result_enums:
            add_enum_error(errors, "alignment_state.round_result", status.get("alignment_state", {}).get("round_result"), round_result_enums)
        if has_text(status.get("fallback_state", {}).get("fallback_type")):
            if status.get("fallback_state", {}).get("fallback_type") not in fallback_enums:
                add_enum_error(errors, "fallback_state.fallback_type", status.get("fallback_state", {}).get("fallback_type"), fallback_enums)
            if not has_text(status.get("fallback_state", {}).get("fallback_reason")):
                errors.append("fallback_state.fallback_reason 为空")
        if (
            status.get("fallback_state", {}).get("fallback_type") == "reopen_alignment"
            and status.get("alignment_state", {}).get("round_result") == "ready_for_preflight"
        ):
            errors.append("reopen_alignment 不能与 ready_for_preflight 同时存在")
        if has_items(status.get("pending_confirmations")) and status.get("fallback_state", {}).get("fallback_type") not in {"internal_repair", "need_materials"}:
            add_ask_back_error(errors, "pending_confirmations 未清空，且未标为 internal_repair / need_materials", "请先确认当前最阻塞的待确认项，再继续下一轮调研。")
        if not (has_text(status.get("baselines", {}).get("response_plan")) or has_items(status.get("artifacts", {}).get("response_notes"))):
            errors.append("缺少调研产物，无法继续方案阶段")
        if not has_text(status.get("next_recommended")):
            errors.append("next_recommended 为空")
    elif gate == "omp-preflight":
        if not has_anchors_state_meta(status):
            errors.append("anchors_state.meta 不完整")
        if not has_module_anchors(status):
            errors.append("anchors_state.anchors.modules 为空")
        if not has_page_or_flow_anchors(status):
            errors.append("缺少页面或流程锚点")
        if has_anchors_state_reference_mismatch(status):
            errors.append("shared_refs 与动作引用未对齐")
        if not has_solution_baseline(status):
            errors.append("baselines.solution 缺失")
        if not has_solution_notes(status):
            errors.append("artifacts.solution_notes 为空")
        if not has_anchor_manifest(status):
            errors.append("anchors_state.meta.anchor_manifest 缺失")
        if not can_progress_by_anchors_state(status):
            errors.append("进入预检前 anchors_state.meta.can_progress 必须为 true")
        if status.get("alignment_state", {}).get("round_result") not in round_result_enums:
            add_enum_error(errors, "alignment_state.round_result", status.get("alignment_state", {}).get("round_result"), round_result_enums)
        if status.get("alignment_state", {}).get("round_result") != "ready_for_preflight":
            errors.append("进入预检前 alignment_state.round_result 必须为 ready_for_preflight")
        if has_text(status.get("fallback_state", {}).get("fallback_type")):
            if status.get("fallback_state", {}).get("fallback_type") not in fallback_enums:
                add_enum_error(errors, "fallback_state.fallback_type", status.get("fallback_state", {}).get("fallback_type"), fallback_enums)
            if status.get("fallback_state", {}).get("fallback_type") == "reopen_alignment":
                errors.append("reopen_alignment 状态下不能直接进入预检")
        if has_items(status.get("pending_confirmations")):
            add_ask_back_error(errors, "开工检查前 pending_confirmations 未清空", "请先确认当前仍未闭合的范围或事实边界，再继续开工检查。")
        if not (has_text(status.get("baselines", {}).get("response_plan")) or has_items(status.get("artifacts", {}).get("response_notes"))):
            errors.append("缺少稳定回应产物")
        if not has_text(status.get("context_summary")):
            errors.append("context_summary 为空")
    elif gate == "omp-deliver":
        if not has_anchors_state_meta(status):
            errors.append("anchors_state.meta 不完整")
        if not has_module_anchors(status):
            errors.append("anchors_state.anchors.modules 为空")
        if not has_page_or_flow_anchors(status):
            errors.append("缺少页面或流程锚点")
        if has_anchors_state_reference_mismatch(status):
            errors.append("shared_refs 与动作引用未对齐")
        if not has_solution_baseline(status):
            errors.append("baselines.solution 缺失")
        if not has_solution_notes(status):
            errors.append("artifacts.solution_notes 为空")
        if not has_anchor_manifest(status):
            errors.append("anchors_state.meta.anchor_manifest 缺失")
        if not can_progress_by_anchors_state(status):
            errors.append("正式交付前 anchors_state.meta.can_progress 必须为 true")
        if status.get("alignment_state", {}).get("round_result") not in round_result_enums:
            add_enum_error(errors, "alignment_state.round_result", status.get("alignment_state", {}).get("round_result"), round_result_enums)
        if status.get("alignment_state", {}).get("round_result") != "ready_for_preflight":
            errors.append("正式交付前 alignment_state.round_result 必须为 ready_for_preflight")
        if has_text(status.get("fallback_state", {}).get("fallback_type")):
            if status.get("fallback_state", {}).get("fallback_type") not in fallback_enums:
                add_enum_error(errors, "fallback_state.fallback_type", status.get("fallback_state", {}).get("fallback_type"), fallback_enums)
            errors.append("正式交付前 fallback_state.fallback_type 必须为空")
        if has_items(status.get("pending_confirmations")):
            add_ask_back_error(errors, "正式交付前 pending_confirmations 未清空", "请先确认当前仍未闭合的范围或事实边界，再继续原型或 PRD 交付。")
        if not has_text(status.get("baselines", {}).get("response_plan")):
            errors.append("baselines.response_plan 缺失")
        if has_items(status.get("review_state", {}).get("must_fix_before_next_stage")):
            errors.append("review_state.must_fix_before_next_stage 未清空")
    elif gate == "omp-change":
        if status.get("change_state", {}).get("change_category") not in change_enums:
            add_enum_error(errors, "change_state.change_category", status.get("change_state", {}).get("change_category"), change_enums)
        if has_items(status.get("pending_confirmations")):
            add_ask_back_error(errors, "变更处理前 pending_confirmations 未清空", "请先确认当前变更涉及的关键事实或范围边界。")
        if not status.get("change_state", {}).get("change_category_confirmed_by_pm"):
            add_ask_back_error(errors, "change_category_confirmed_by_pm 仍未确认", f"当前请求是否最终确认保持 '{status.get('change_state', {}).get('change_category')}' 这个分类？")
        if not has_text(status.get("baselines", {}).get("prototype")) and not has_text(status.get("baselines", {}).get("prd")):
            errors.append("缺少正式交付基线")
    if errors:
        for item in errors:
            print(f"[OhMyPm] 门禁问题：{item}")
        fail(f"门禁未通过：{gate}")
    print(f"[OhMyPm] 门禁通过：{gate}")
    return 0


def cmd_change_apply(params: dict[str, Any]) -> int:
    change_path = resolve_project_path(Path.cwd(), str(params["ChangeJsonPath"]))
    if not change_path.exists():
        fail(f"变更结果文件不存在：{params['ChangeJsonPath']}")
    change = read_utf8_json(change_path)
    ensure_one_of(change.get("change_category"), ["minor_patch", "within_module", "new_module", "structural_change"], "change_category")
    if change.get("change_category_confirmed_by_pm") is None:
        fail("缺少字段：change_category_confirmed_by_pm")
    if change["change_category"] in {"new_module", "structural_change"} and not bool(change["change_category_confirmed_by_pm"]):
        fail(f"重变更分类未确认：{change['change_category']}")
    stage = "omp-change"
    mode = "change_control"
    fallback_type = ""
    fallback_reason = ""
    round_result = None
    next_action = change.get("next_action")
    if change["change_category"] == "minor_patch":
        stage = "omp-fix"
        mode = "formal_delivery"
        next_action = next_action or "下一步：按小修补处理，留在当前交付范围内修正。"
    elif change["change_category"] == "within_module":
        stage = "omp-fix"
        mode = "formal_delivery"
        next_action = next_action or "下一步：按模块内补充处理，留在当前交付范围内修正。"
    elif change["change_category"] == "new_module":
        stage = "omp-disc"
        mode = "alignment_loop"
        fallback_type = "reopen_alignment"
        fallback_reason = "change_category=new_module"
        round_result = "continue_alignment"
        next_action = next_action or "下一步：回到调研，按新模块重建范围和交付边界。"
    else:
        stage = "omp-disc"
        mode = "alignment_loop"
        fallback_type = "reopen_alignment"
        fallback_reason = "change_category=structural_change"
        round_result = "continue_alignment"
        next_action = next_action or "下一步：回到调研，按结构性变化重建范围和交付边界。"
    forwarded: dict[str, Any] = {
        "Stage": stage,
        "Mode": mode,
        "LastAction": "change_apply",
        "NextRecommended": next_action,
        "ChangeCategory": change["change_category"],
        "ChangeCategoryConfirmedByPm": bool(change["change_category_confirmed_by_pm"]),
    }
    if fallback_type:
        forwarded["FallbackType"] = fallback_type
        forwarded["FallbackReason"] = fallback_reason
    if round_result is not None:
        forwarded["RoundResult"] = round_result
    if has_text(change.get("change_record_path")):
        forwarded["ArtifactField"] = "change_records"
        forwarded["ArtifactPath"] = change["change_record_path"]
    return cmd_artifact_sync(forwarded)


def cmd_overwrite_judge(params: dict[str, Any]) -> int:
    affected = parse_json_array(params.get("AffectedUpstreamJson", "[]"), "AffectedUpstreamJson")
    writeback_targets = parse_json_array(params.get("WritebackTargetsJson", "[]"), "WritebackTargetsJson")
    propagation_raw = params.get("PropagationCheckJson", "{}")
    propagation_check = {} if not has_text(propagation_raw) else json.loads(str(propagation_raw))
    ensure_one_of(params.get("ConflictType", "missing_rule"), ["missing_scope", "missing_rule", "structure_conflict", "baseline_stale", "review_reversal"], "ConflictType")
    ensure_one_of(params.get("Severity", "medium"), ["low", "medium", "high"], "Severity")
    ensure_one_of(params.get("ActionLevel", "patch"), ["patch", "rollback_upstream", "restart_alignment"], "ActionLevel")
    can_continue = not parse_bool_value(params.get("VersionUnclear", False), "VersionUnclear") and params.get("ActionLevel", "patch") != "restart_alignment"
    return output(
        {
            "propagation_check": propagation_check,
            "affected_upstream": affected,
            "conflict_type": params.get("ConflictType", "missing_rule"),
            "severity": params.get("Severity", "medium"),
            "action_level": params.get("ActionLevel", "patch"),
            "writeback_targets": writeback_targets,
            "can_continue": can_continue,
            "reason": params.get("Reason", ""),
        }
    )


def cmd_overwrite_apply(params: dict[str, Any]) -> int:
    judge_path = resolve_project_path(Path.cwd(), str(params["JudgeJsonPath"]))
    if not judge_path.exists():
        fail(f"复写判断文件不存在：{params['JudgeJsonPath']}")
    judge = read_utf8_json(judge_path)
    ensure_one_of(judge.get("conflict_type"), ["missing_scope", "missing_rule", "structure_conflict", "baseline_stale", "review_reversal"], "conflict_type")
    ensure_one_of(judge.get("action_level"), ["patch", "rollback_upstream", "restart_alignment"], "action_level")
    if judge.get("can_continue") is None:
        fail("缺少字段：can_continue")
    queue_item = [
        {
            "propagation_check": judge.get("propagation_check"),
            "affected_upstream": judge.get("affected_upstream"),
            "conflict_type": judge.get("conflict_type"),
            "severity": judge.get("severity"),
            "action_level": judge.get("action_level"),
            "writeback_targets": judge.get("writeback_targets"),
            "reason": judge.get("reason"),
        }
    ]
    next_action = "下一步：留在当前阶段继续处理复写。" if judge.get("can_continue") else "下一步：回到调研，修正上游产物后再继续。"
    stage = "omp-fix"
    mode = "formal_delivery"
    fallback_type = "internal_repair"
    fallback_reason = f"overwrite_conflict={judge.get('conflict_type')}"
    round_result = None
    if judge.get("action_level") == "restart_alignment":
        if bool(judge.get("can_continue")):
            fail("restart_alignment 不能设置 can_continue=true")
        stage = "omp-disc"
        mode = "alignment_loop"
        fallback_type = "reopen_alignment"
        next_action = "下一步：回到调研，修正上游产物后再继续。"
        round_result = "continue_alignment"
    forwarded = {
        "Stage": stage,
        "Mode": mode,
        "LastAction": "overwrite_apply",
        "NextRecommended": next_action,
        "FallbackType": fallback_type,
        "FallbackReason": fallback_reason,
        "OverwriteQueueJson": json_compact(queue_item),
    }
    if round_result is not None:
        forwarded["RoundResult"] = round_result
    return cmd_artifact_sync(forwarded)


def cmd_review_apply(params: dict[str, Any]) -> int:
    review_path = resolve_project_path(Path.cwd(), str(params["ReviewJsonPath"]))
    if not review_path.exists():
        fail(f"评审结果文件不存在：{params['ReviewJsonPath']}")
    review = read_utf8_json(review_path)
    if "unified_conclusion" not in review:
        fail("缺少字段：unified_conclusion")
    if "change_propagation" not in review:
        fail("缺少字段：change_propagation")
    propagation_status = review["change_propagation"].get("status")
    ensure_one_of(propagation_status, ["complete", "incomplete", "not_applicable"], "change_propagation.status")
    unified = review["unified_conclusion"]
    result = unified.get("result")
    ensure_one_of(result, ["pass", "conditional_pass", "rework_required", "defer"], "unified_conclusion.result")
    must_fix = as_list(unified.get("must_fix_before_next_stage"))
    next_action = unified.get("next_action")
    can_continue = unified.get("can_continue")
    if can_continue is None:
        fail("缺少字段：unified_conclusion.can_continue")
    if result == "pass" and must_fix:
        fail("pass 结论下不得保留 must_fix_before_next_stage")
    if result == "pass" and propagation_status == "incomplete":
        fail("change_propagation.status=incomplete 时不得给出 pass 结论")
    if result in {"conditional_pass", "rework_required"} and not must_fix:
        fail(f"{result} 结论下必须存在 must_fix_before_next_stage")
    if result == "pass" and not bool(can_continue):
        fail("pass 结论不能设置 can_continue=false")
    if result in {"rework_required", "defer"} and bool(can_continue):
        fail(f"{result} 结论不能设置 can_continue=true")
    forwarded = {
        "LastAction": "review_apply",
        "NextRecommended": next_action,
        "ReviewResult": result,
        "ReviewMustFixJson": json_compact(must_fix),
    }
    if result == "pass":
        forwarded["Stage"] = "omp-review"
        forwarded["FallbackType"] = ""
        forwarded["FallbackReason"] = ""
        forwarded["OverwriteQueueJson"] = "[]"
    elif result == "conditional_pass":
        forwarded["Stage"] = "omp-fix"
        forwarded["FallbackType"] = "internal_repair"
        forwarded["FallbackReason"] = "review_result=conditional_pass"
    elif result == "rework_required":
        forwarded["Stage"] = "omp-fix"
        forwarded["FallbackType"] = "internal_repair"
        forwarded["FallbackReason"] = "review_result=rework_required"
    else:
        forwarded["Stage"] = "omp-disc"
        forwarded["FallbackType"] = "need_materials"
        forwarded["FallbackReason"] = "review_result=defer"
    return cmd_artifact_sync(forwarded)


def summarize_manifest(manifest: dict[str, Any]) -> dict[str, Any]:
    modules = as_list(manifest.get("modules"))
    pages = 0
    actions = 0
    module_names: list[str] = []
    for module in modules:
        if has_text(module.get("module_name")):
            module_names.append(str(module["module_name"]))
        for page in as_list(module.get("pages")):
            pages += 1
            actions += len(as_list(page.get("actions")))
    return {
        "module_count": len(modules),
        "page_count": pages,
        "action_count": actions,
        "module_names": module_names,
    }


def cmd_context_lint(params: dict[str, Any]) -> int:
    errors: list[str] = []
    warnings: list[str] = []
    checked: list[str] = []
    status_path = resolve_status_path(str(params.get("StatusPath", ".ohmypm/status.json")))
    if not status_path.exists():
        errors.append(f"状态文件不存在：{params.get('StatusPath', '.ohmypm/status.json')}")
        result = {"tool": "context-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked}
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 1
    try:
        status = read_utf8_json(status_path)
    except json.JSONDecodeError:
        errors.append(f"状态文件不是合法 UTF-8 JSON：{params.get('StatusPath', '.ohmypm/status.json')}")
        result = {"tool": "context-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked}
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 1
    checked.append("status-json-readable")
    package = status.get("context_package")
    if not isinstance(package, dict):
        errors.append("缺少 context_package")
        result = {"tool": "context-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked}
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 1
    checked.append("context_package-present")
    if not has_text(package.get("request_summary")):
        errors.append("context_package.request_summary 为空")
    checked.append("request_summary")
    allowed_shapes = ["iteration", "new_build", "hybrid", "暂不能判断"]
    if "solution_shape" not in package:
        errors.append("context_package.solution_shape 字段缺失")
    elif not has_text(package.get("solution_shape")):
        errors.append("context_package.solution_shape 为空")
    elif str(package.get("solution_shape")) not in allowed_shapes:
        errors.append(f"context_package.solution_shape 非法：{package.get('solution_shape')}")
    checked.append("solution_shape")
    if not has_text(package.get("business_stage")):
        errors.append("context_package.business_stage 为空")
    checked.append("business_stage")
    for field in ["system_or_page_clues", "material_paths", "context_gaps"]:
        if field not in package:
            errors.append(f"context_package.{field} 字段缺失")
        checked.append(f"context_package.{field}")
    project_root = get_project_root_from_status(status_path)
    material_paths = [item for item in as_list(package.get("material_paths")) if has_text(item)]
    if not material_paths:
        warnings.append("context_package.material_paths 为空；允许继续，但后续不得伪装已有资料依据")
    for item in material_paths:
        if not resolve_project_path(project_root, str(item)).exists():
            warnings.append(f"资料路径不可访问：{item}")
    checked.append("material_paths-accessibility")
    gaps = [item for item in as_list(package.get("context_gaps")) if has_text(item)]
    if not gaps:
        warnings.append("context_package.context_gaps 为空；如仍有影响推进的缺口，应显式记录")
    checked.append("context_gaps")
    meta = status.get("anchors_state", {}).get("meta")
    if isinstance(meta, dict):
        for fact in [item for item in as_list(meta.get("confirmed_facts")) if has_text(item)]:
            if re.search(r"未确认|待确认|待澄清|不确定|可能|疑似|open question|pending confirmation", str(fact)):
                errors.append(f"confirmed_facts 混入未确认口径：{fact}")
        checked.append("confirmed_facts-boundary")
        open_questions = [item for item in as_list(meta.get("open_questions")) if has_text(item)]
        if open_questions and bool(meta.get("can_progress")):
            errors.append("open_questions 非空但 anchors_state.meta.can_progress=true")
        checked.append("open_questions-can_progress")
    else:
        warnings.append("anchors_state.meta 缺失；context-lint 仅完成上下文包检查")
    result = "fail" if errors else "warn" if warnings else "pass"
    payload = {"tool": "context-lint", "result": result, "errors": errors, "warnings": warnings, "checked": checked}
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    return 1 if errors else 0


def cmd_trace_lint(params: dict[str, Any]) -> int:
    errors: list[str] = []
    warnings: list[str] = []
    checked: list[str] = []
    summary = {"modules": 0, "pages": 0, "actions": 0, "prototype_markers": 0}
    status_path = resolve_status_path(str(params.get("StatusPath", ".ohmypm/status.json")))
    if not status_path.exists():
        errors.append(f"状态文件不存在：{params.get('StatusPath', '.ohmypm/status.json')}")
        payload = {"tool": "trace-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1
    try:
        status = read_utf8_json(status_path)
    except json.JSONDecodeError:
        errors.append(f"状态文件不是合法 UTF-8 JSON：{params.get('StatusPath', '.ohmypm/status.json')}")
        payload = {"tool": "trace-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1
    checked.append("status-json-readable")
    anchor_manifest = status.get("anchors_state", {}).get("meta", {}).get("anchor_manifest")
    if not has_text(anchor_manifest):
        errors.append("anchors_state.meta.anchor_manifest 缺失")
        payload = {"tool": "trace-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1
    project_root = get_project_root_from_status(status_path)
    manifest_path = resolve_project_path(project_root, str(anchor_manifest))
    if not manifest_path.exists():
        errors.append(f"manifest 路径不存在：{anchor_manifest}")
        payload = {"tool": "trace-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1
    try:
        manifest = read_utf8_json(manifest_path)
    except json.JSONDecodeError:
        errors.append(f"manifest 不是合法 UTF-8 JSON：{anchor_manifest}")
        payload = {"tool": "trace-lint", "result": "fail", "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1
    checked.append("manifest-json-readable")
    modules = as_list(manifest.get("modules"))
    if not modules:
        errors.append("manifest.modules 为空")
    manifest_markers: set[str] = set()
    for module in modules:
        summary["modules"] += 1
        if not has_text(module.get("module_id")):
            errors.append("模块缺少 module_id")
        if not has_text(module.get("module_name")):
            errors.append(f"模块缺少 module_name：{module.get('module_id')}")
        pages = as_list(module.get("pages"))
        if not pages:
            errors.append(f"模块缺少 pages：{module.get('module_id')}")
        for page in pages:
            summary["pages"] += 1
            if not has_text(page.get("page_id")):
                errors.append(f"页面缺少 page_id：{module.get('module_id')}")
            if not has_text(page.get("page_name")):
                errors.append(f"页面缺少 page_name：{module.get('module_id')}/{page.get('page_id')}")
            if not has_text(page.get("human_page_code")):
                warnings.append(f"页面缺少 human_page_code：{module.get('module_id')}/{page.get('page_id')}")
            actions = as_list(page.get("actions"))
            if not actions:
                errors.append(f"页面缺少 actions：{module.get('module_id')}/{page.get('page_id')}")
            for action in actions:
                summary["actions"] += 1
                anchor_id = action.get("anchor_id")
                if not has_text(anchor_id):
                    errors.append(f"动作缺少 anchor_id：{module.get('module_id')}/{page.get('page_id')}")
                elif not re.match(r"^M\d{2}-P\d{2}-A\d{2}$", str(anchor_id)):
                    errors.append(f"anchor_id 格式非法：{anchor_id}")
                if not has_text(action.get("action_name")):
                    errors.append(f"动作缺少 action_name：{anchor_id}")
                if "prd_locator" not in action:
                    errors.append(f"动作缺少 prd_locator：{anchor_id}")
                if "prototype_locator" not in action:
                    errors.append(f"动作缺少 prototype_locator：{anchor_id}")
                prototype_locator = action.get("prototype_locator") or {}
                if has_text(prototype_locator.get("marker")):
                    manifest_markers.add(str(prototype_locator["marker"]))
    summary["prototype_markers"] = len(manifest_markers)
    checked.append("manifest-anchor-structure")
    prd_paths: list[str] = []
    if has_text(status.get("baselines", {}).get("prd")):
        prd_paths.append(str(status["baselines"]["prd"]))
    if has_text(status.get("artifacts", {}).get("prd")):
        prd_paths.append(str(status["artifacts"]["prd"]))
    prd_paths = list(dict.fromkeys([item for item in prd_paths if has_text(item)]))
    for item in prd_paths:
        if not resolve_project_path(project_root, item).exists():
            errors.append(f"PRD 路径不存在：{item}")
    checked.append("prd-paths")
    prototype_paths: list[str] = []
    if has_text(status.get("baselines", {}).get("prototype")):
        prototype_paths.append(str(status["baselines"]["prototype"]))
    prototype_paths.extend([str(item) for item in as_list(status.get("artifacts", {}).get("prototypes")) if has_text(item)])
    prototype_paths = list(dict.fromkeys(prototype_paths))
    for item in prototype_paths:
        if not resolve_project_path(project_root, item).exists():
            errors.append(f"原型路径不存在：{item}")
    checked.append("prototype-paths")
    output_path = project_root / "output"
    if output_path.exists():
        leak_pattern = re.compile(r"M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref|data-anchor")
        for file_path in output_path.rglob("*"):
            if not file_path.is_file():
                continue
            try:
                for idx, line in enumerate(read_utf8_text(file_path).splitlines(), start=1):
                    if leak_pattern.search(line):
                        errors.append(f"人读产物泄漏机读字段：{file_path.relative_to(project_root)}:{idx}")
            except UnicodeDecodeError:
                continue
    checked.append("output-machine-field-leak")
    html_markers: set[str] = set()
    html_marker_pattern = re.compile(r'data-anno=["\']([^"\']+)["\']|showAnno\(["\']([^"\']+)["\']')
    for item in prototype_paths:
        if not re.search(r"\.html?$", item, re.IGNORECASE):
            continue
        prototype_path = resolve_project_path(project_root, item)
        if not prototype_path.exists():
            continue
        content = read_utf8_text(prototype_path)
        for match in html_marker_pattern.finditer(content):
            marker = match.group(1) or match.group(2)
            if has_text(marker):
                html_markers.add(str(marker))
    if html_markers and manifest_markers:
        for marker in manifest_markers:
            if marker not in html_markers:
                warnings.append(f"manifest 中的原型标注未在 HTML 中找到：{marker}")
    elif html_markers and not manifest_markers:
        warnings.append("HTML 中存在标注，但 manifest 未提供 prototype_locator.marker；当前仅提示，不阻断")
    checked.append("prototype-marker-mapping")
    result = "fail" if errors else "warn" if warnings else "pass"
    payload = {"tool": "trace-lint", "result": result, "errors": errors, "warnings": warnings, "checked": checked, "summary": summary}
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    return 1 if errors else 0


def cmd_review_pack(params: dict[str, Any]) -> int:
    status_path, project_root, status = load_status(str(params.get("StatusPath", ".ohmypm/status.json")))
    output_path = resolve_project_path(project_root, str(params.get("OutputPath", ".ohmypm/review/review-pack.json")))
    context_exit, context_raw, context_json = invoke_internal_tool("context-lint", {"StatusPath": str(status_path)})
    trace_exit, trace_raw, trace_json = invoke_internal_tool("trace-lint", {"StatusPath": str(status_path)})
    manifest_summary = {"module_count": 0, "page_count": 0, "action_count": 0, "module_names": []}
    anchor_manifest = status.get("anchors_state", {}).get("meta", {}).get("anchor_manifest")
    if has_text(anchor_manifest):
        manifest_path = resolve_project_path(project_root, str(anchor_manifest))
        if manifest_path.exists():
            try:
                manifest_summary = summarize_manifest(read_utf8_json(manifest_path))
            except json.JSONDecodeError:
                manifest_summary = {"error": "manifest 无法解析"}
    pack = {
        "generated_at": __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "project_root": str(project_root),
        "status_summary": {
            "current_stage": status.get("current_stage"),
            "current_mode": status.get("current_mode"),
            "current_version": status.get("current_version"),
            "next_recommended": status.get("next_recommended"),
            "blockers": as_list(status.get("blockers")),
            "pending_confirmations": as_list(status.get("pending_confirmations")),
        },
        "baselines": status.get("baselines"),
        "artifacts": {
            "prototypes": as_list(status.get("artifacts", {}).get("prototypes")),
            "prd": status.get("artifacts", {}).get("prd", ""),
            "review_records": as_list(status.get("artifacts", {}).get("review_records")),
        },
        "traceability": {
            "anchor_manifest": anchor_manifest or "",
            "manifest_summary": manifest_summary,
        },
        "lint_results": {
            "context_lint": {"exit_code": context_exit, "parsed": context_json, "raw": context_raw},
            "trace_lint": {"exit_code": trace_exit, "parsed": trace_json, "raw": trace_raw},
        },
        "review_inputs": {
            "use_this_pack_only": True,
            "instruction": "评审时基于本冷启动包、PRD、原型和 manifest 重新判断，不沿用 writer 长上下文惯性。",
        },
    }
    write_json(output_path, pack)
    return output(
        {
            "tool": "review-pack",
            "result": "pass",
            "output_path": str(params.get("OutputPath", ".ohmypm/review/review-pack.json")),
            "context_lint_result": context_json.get("result") if isinstance(context_json, dict) else "unparsed",
            "trace_lint_result": trace_json.get("result") if isinstance(trace_json, dict) else "unparsed",
        }
    )


def cmd_review_panel(params: dict[str, Any]) -> int:
    roles = parse_json_array(params.get("RolesJson", '["demand","pm","dev","qa","delivery","legacy_guard"]'), "RolesJson")
    fact_issues = parse_json_array(params.get("FactIssuesJson", "[]"), "FactIssuesJson")
    risk_issues = parse_json_array(params.get("RiskIssuesJson", "[]"), "RiskIssuesJson")
    suggestion_issues = parse_json_array(params.get("SuggestionIssuesJson", "[]"), "SuggestionIssuesJson")
    must_fix = parse_json_array(params.get("MustFixJson", "[]"), "MustFixJson")
    ensure_one_of(params.get("Conclusion", "conditional_pass"), ["pass", "conditional_pass", "rework_required", "defer"], "Conclusion")
    conclusion = str(params.get("Conclusion", "conditional_pass"))
    can_continue = conclusion in {"pass", "conditional_pass"}
    return output(
        {
            "roles": roles,
            "fact_issues": fact_issues,
            "risk_issues": risk_issues,
            "suggestion_issues": suggestion_issues,
            "unified_conclusion": {
                "result": conclusion,
                "next_action": params.get("NextAction", ""),
                "must_fix_before_next_stage": must_fix,
                "can_continue": can_continue,
            },
        }
    )


def cmd_ompgo(params: dict[str, Any]) -> int:
    status_path_raw = str(params.get("StatusPath", ".ohmypm/status.json"))
    memory_path_raw = str(params.get("MemoryPath", ".ohmypm/memory.md"))
    status_path = resolve_status_path(status_path_raw)
    if not status_path.exists():
        init_script = REPO_ROOT / "scripts" / "control" / "init-project.ps1"
        completed = subprocess.run(
            ["powershell", "-NoProfile", "-File", str(init_script)],
            cwd=str(Path.cwd()),
            capture_output=True,
            text=False,
        )
        if completed.returncode != 0:
            stderr_text = completed.stderr.decode("utf-8", errors="replace") if completed.stderr else ""
            fail(f"ohmypm-status.json not found after init. {stderr_text}".strip())
    status_path = resolve_status_path(status_path_raw)
    if not status_path.exists():
        fail("ohmypm-status.json not found after init.")
    if memory_path_raw == ".ohmypm/memory.md":
        memory_path = status_path.parent / "memory.md"
    else:
        memory_path = resolve_status_path(memory_path_raw)
    if not memory_path.exists():
        fail("ohmypm-memory.md not found.")

    route_exit, route_raw, route = invoke_internal_tool(
        "route-resolve",
        {
            "IntentText": params.get("IntentText", ""),
            "ForceSkill": params.get("ForceSkill", ""),
            "StatusPath": str(status_path),
        },
    )
    if route_exit != 0 or not isinstance(route, dict):
        fail(route_raw or "route-resolve 执行失败")

    skill = route.get("skill")
    action_name = route.get("action_name")
    gate_name = route.get("gate_name")
    contracts = as_list(route.get("required_contracts"))
    skill_path = route.get("skill_path")

    next_recommended = f"下一步：进入 {action_name}，并只加载 {skill_path} 与当前动作必要规则。"
    gate_passed = True
    ask_back_required = False
    internal_repair_required = False

    if has_text(gate_name):
        gate_exit, _, _ = invoke_internal_tool("stage-gate", {"Gate": gate_name, "Path": str(status_path)})
        if gate_exit != 0:
            gate_passed = False
            ask_exit, ask_raw, ask_result = invoke_internal_tool("ask-back-plan", {"Path": str(status_path)})
            if ask_exit == 0 and isinstance(ask_result, dict):
                ask_back_required = bool(ask_result.get("ask_back_required"))
                internal_repair_required = bool(ask_result.get("internal_placeholder_required"))
                if ask_back_required and int(ask_result.get("trigger_count", 0)) > 0:
                    triggers = as_list(ask_result.get("triggers"))
                    question_text = triggers[0].get("minimal_question") if triggers and isinstance(triggers[0], dict) else ""
                    if has_text(question_text):
                        next_recommended = f"现在只需要你回答的唯一问题是：{question_text}"
                elif internal_repair_required:
                    next_recommended = "下一步：先做内部修正，把当前状态里的冲突、缺口或引用失配补齐后再继续。"
                else:
                    next_recommended = "下一步：先补齐当前动作缺失条件，再重新判断是否可以继续推进。"
            else:
                next_recommended = ask_raw or "下一步：先补齐当前动作缺失条件，再重新判断是否可以继续推进。"

    _, _, control_status = load_status(str(status_path))
    update_status(
        control_status,
        status_path,
        {
            "LastAction": f"Control dispatch -> {action_name}",
            "NextRecommended": next_recommended,
        },
    )

    result = {
        "route": {
            "current_stage": route.get("current_stage"),
            "current_mode": route.get("current_mode"),
            "skill": skill,
            "skill_path": skill_path,
            "action_name": action_name,
            "gate_name": gate_name,
            "required_contracts": contracts,
        },
        "control": {
            "gate_checked": has_text(gate_name),
            "gate_passed": gate_passed,
            "ask_back_required": ask_back_required,
            "internal_repair_required": internal_repair_required,
        },
        "files": {
            "status": status_path_raw,
            "memory": memory_path_raw,
        },
        "output": {
            "final_line": next_recommended,
        },
    }

    if params.get("AsJson"):
        return output(result)
    print(next_recommended)
    return 0


TOOL_MAP = {
    "status-read": cmd_status_read,
    "status-write": cmd_status_write,
    "artifact-sync": cmd_artifact_sync,
    "status-apply": cmd_status_apply,
    "memory-write": cmd_memory_write,
    "memory-apply": cmd_memory_apply,
    "ask-back-apply": cmd_ask_back_apply,
    "ask-back-plan": cmd_ask_back_plan,
    "state-machine": cmd_state_machine,
    "route-resolve": cmd_route_resolve,
    "stage-gate": cmd_stage_gate,
    "change-apply": cmd_change_apply,
    "overwrite-judge": cmd_overwrite_judge,
    "overwrite-apply": cmd_overwrite_apply,
    "review-apply": cmd_review_apply,
    "context-lint": cmd_context_lint,
    "trace-lint": cmd_trace_lint,
    "review-pack": cmd_review_pack,
    "review-panel": cmd_review_panel,
    "ompgo": cmd_ompgo,
}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tool", choices=sorted(TOOL_MAP.keys()))
    parser.add_argument("--params-json", default="{}")
    parser.add_argument("--status-path")
    parser.add_argument("--output-path")
    parser.add_argument("--gate")
    parser.add_argument("--path")
    parser.add_argument("--memory-path")
    parser.add_argument("--payload-path")
    parser.add_argument("--intent-text")
    parser.add_argument("--force-skill")
    parser.add_argument("--as-json", action="store_true")
    args = parser.parse_args()
    try:
        params = json.loads(args.params_json)
        if not isinstance(params, dict):
            fail("params-json 必须是 JSON object")
        cli_params = {
            "StatusPath": args.status_path,
            "OutputPath": args.output_path,
            "Gate": args.gate,
            "Path": args.path,
            "MemoryPath": args.memory_path,
            "PayloadPath": args.payload_path,
            "IntentText": args.intent_text,
            "ForceSkill": args.force_skill,
        }
        for key, value in cli_params.items():
            if value is not None:
                params[key] = value
        if args.as_json:
            params["AsJson"] = True
        return TOOL_MAP[args.tool](params)
    except OhMyPmError as exc:
        print(f"[OhMyPm] {exc}", file=sys.stderr)
        return 1
    except json.JSONDecodeError as exc:
        print(f"[OhMyPm] params-json 不是合法 JSON: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
