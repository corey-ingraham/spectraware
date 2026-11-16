# thinkRF manuals

Vendor reference for the thinkRF R6000 real-time spectrum analyzer and SpectraWare. Each document is kept
as the original PDF plus a `pdftotext -layout` text copy. The text copy is for searching; the PDF is
authoritative when they disagree (tables and figures lose structure in the text).

| Document | Doc no. | Pages | PDF | Text | Use it for |
|---|---|---|---|---|---|
| R6000 Real-Time Signal Analyzer User Guide | 75-0054 | 27 | [pdf](R6000-user-guide-75-0054.pdf) | [txt](R6000-user-guide-75-0054.txt) | setup, networking (DHCP / link-local), LEDs, connectors and pinouts, firmware update, maintenance |
| R6000 Real-Time Spectrum Analyzer Programmer's Guide | 75-0055 | 155 | [pdf](R6000-programmers-guide-75-0055.pdf) | [txt](R6000-programmers-guide-75-0055.txt) | SCPI command set, VRT data streaming, ports, UDP discovery, capture and sweep programming |
| R6000 Datasheet | 74-0141 | 7 | [pdf](R6000-datasheet-74-0141.pdf) | [txt](R6000-datasheet-74-0141.txt) | specifications: frequency range, bandwidth, dynamic range, interfaces (USB 3.0, Ethernet), size, power |
| App note: Optimizing Streaming Bandwidth for Contiguous Capture with R6000 | 74-0142 | 8 | [pdf](R6000-app-note-streaming-bandwidth-74-0142.pdf) | [txt](R6000-app-note-streaming-bandwidth-74-0142.txt) | gap-free streaming: USB 3 (1550 Mbps) vs 1 GigE (720 Mbps), decimation / sample-size trade-offs, the SCPI commands that set data rate |

- Source: thinkRF, downloaded 2026-11-16. Latest editions: <https://thinkrf.com/documentation/>.
- The User Guide PDF's embedded title metadata reads "ThinkRF R5750 User Guide"; its content is the R6000 guide.
- Regenerate text: `pdftotext -layout <file>.pdf <file>.txt`.

Copyright © 2024 thinkRF Corporation, all rights reserved. These documents are thinkRF's proprietary
material, reproduced here unmodified for reference; they are not covered by this repository's licence.
Contact thinkRF (support@thinkrf.com) for the official, current versions.
