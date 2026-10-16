"""Validate learning content before it reaches child-facing lessons."""
import collections
import json
import pathlib
import sys

KINDS = {"imageMatching", "wordJumble", "audioListening", "speechRecognition"}


def validate(units):
    errors = []
    seen = set()
    def check_id(obj, path):
        value = obj.get("id")
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: missing id")
        elif value in seen:
            errors.append(f"{path}: duplicate id {value}")
        else:
            seen.add(value)

    if not isinstance(units, list) or not units:
        return ["root: expected a non-empty list of units"]
    for ui, unit in enumerate(units):
        p = f"units[{ui}]"
        if not isinstance(unit, dict):
            errors.append(f"{p}: expected object")
            continue
        check_id(unit, p)
        if not isinstance(unit.get("title"), str) or not unit["title"].strip():
            errors.append(f"{p}: missing title")
        lessons = unit.get("lessons")
        if not isinstance(lessons, list) or not lessons:
            errors.append(f"{p}: expected non-empty lessons")
            continue
        for li, lesson in enumerate(lessons):
            lp = f"{p}.lessons[{li}]"
            if not isinstance(lesson, dict):
                errors.append(f"{lp}: expected object")
                continue
            check_id(lesson, lp)
            if not isinstance(lesson.get("title"), str) or not lesson["title"].strip():
                errors.append(f"{lp}: missing title")
            xp = lesson.get("xpReward")
            if type(xp) is not int or xp <= 0:
                errors.append(f"{lp}: xpReward must be positive integer")
            questions = lesson.get("questions")
            if not isinstance(questions, list) or not questions:
                errors.append(f"{lp}: expected non-empty questions")
                continue
            for qi, question in enumerate(questions):
                qp = f"{lp}.questions[{qi}]"
                if not isinstance(question, dict):
                    errors.append(f"{qp}: expected object")
                    continue
                check_id(question, qp)
                kind = question.get("type")
                if kind not in KINDS:
                    errors.append(f"{qp}: unknown question type {kind!r}")
                    continue
                if not isinstance(question.get("prompt"), str) or not question["prompt"].strip():
                    errors.append(f"{qp}: missing prompt")
                if kind in {"imageMatching", "audioListening"}:
                    options = question.get("options")
                    if not isinstance(options, list) or len(options) < 2:
                        errors.append(f"{qp}: at least two options required")
                        continue
                    ids = []
                    for option in options:
                        if not isinstance(option, dict) or not isinstance(option.get("id"), str) or not option["id"].strip() or not isinstance(option.get("label"), str) or not option["label"].strip():
                            errors.append(f"{qp}: malformed option")
                            continue
                        ids.append(option["id"])
                    if len(ids) != len(set(ids)):
                        errors.append(f"{qp}: duplicate option ids")
                    if ids.count(question.get("correctOptionId")) != 1:
                        errors.append(f"{qp}: correctOptionId must match exactly one option")
                    if kind == "audioListening" and not (question.get("audioText") or question.get("audioAsset")):
                        errors.append(f"{qp}: missing spoken audio")
                else:
                    answer = question.get("answer")
                    if not isinstance(answer, str) or not answer.strip():
                        errors.append(f"{qp}: missing answer")
                    if kind == "wordJumble":
                        bank = question.get("wordBank")
                        if not isinstance(bank, list) or not all(isinstance(w, str) and w.strip() for w in bank):
                            errors.append(f"{qp}: invalid wordBank")
                        elif isinstance(answer, str) and not (collections.Counter(answer.split()) <= collections.Counter(bank)):
                            errors.append(f"{qp}: answer cannot be formed from wordBank")
    return errors


def main():
    path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path("assets/data/units.json")
    try:
        units = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        print(f"Content could not be loaded: {exc}", file=sys.stderr)
        return 1
    errors = validate(units)
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        print(f"Content validation failed: {len(errors)} issue(s)", file=sys.stderr)
        return 1
    print(f"Validated {len(units)} units, {sum(len(u['lessons']) for u in units)} lessons and {sum(len(l['questions']) for u in units for l in u['lessons'])} questions.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
