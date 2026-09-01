import re

EMAIL_PATTERN = re.compile(
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
)

PHONE_PATTERN = re.compile(
    r"\+\d{1,3}(?:[\s()-]*\d){7,}"
)


def extract_email(text: str) -> str:
    text = re.sub(r"/envel⌢pe", "", text)

    match = EMAIL_PATTERN.search(text)

    return match.group(0) if match else ""


def extract_phone(text: str) -> str:
    match = PHONE_PATTERN.search(text)

    return match.group(0).strip() if match else ""


def extract_candidate_name(text: str) -> str:
    lines = [line.strip() for line in text.splitlines() if line.strip()]

    return lines[0] if lines else ""
