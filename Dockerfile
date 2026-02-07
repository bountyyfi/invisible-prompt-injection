FROM python:3.11-slim

LABEL org.opencontainers.image.title="README Injection Scan"
LABEL org.opencontainers.image.description="Scan documentation for invisible prompt injection patterns"
LABEL org.opencontainers.image.source="https://github.com/bountyyfi/invisible-prompt-injection"
LABEL org.opencontainers.image.authors="Bountyy Oy <info@bountyy.fi>"
LABEL org.opencontainers.image.licenses="MIT"

COPY injection_scan.py /opt/injection-scan/injection_scan.py
COPY entrypoint.sh /opt/injection-scan/entrypoint.sh

RUN chmod +x /opt/injection-scan/entrypoint.sh /opt/injection-scan/injection_scan.py

WORKDIR /workspace

ENTRYPOINT ["/opt/injection-scan/entrypoint.sh"]
