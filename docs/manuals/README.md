# thinkRF manuals

Vendor reference for the thinkRF R6000 real-time spectrum analyzer and SpectraWare. Each manual is kept
as the original PDF plus a `pdftotext -layout` text copy. The text copy is for grep and for Claude; the
PDF is authoritative when they disagree (tables and figures lose structure in the text).

| Manual | Doc no. | Pages | PDF | Text | Use it for |
|---|---|---|---|---|---|
| R6000 Real-Time Signal Analyzer User Guide | 75-0054 | 27 | [pdf](R6000-user-guide-75-0054.pdf) | [txt](R6000-user-guide-75-0054.txt) | setup, networking, LEDs, connectors/pinouts, specs, maintenance |
| R6000 Real-Time Spectrum Analyzer Programmer's Guide | 75-0055 | 155 | [pdf](R6000-programmers-guide-75-0055.pdf) | [txt](R6000-programmers-guide-75-0055.txt) | SCPI command set, VRT data streaming, capture/sweep programming |

- Source: downloaded from thinkRF 2026-11-16. Latest editions: <https://thinkrf.com/documentation/>.
- The User Guide PDF's embedded title metadata reads "ThinkRF R5750 User Guide"; its content is the R6000 guide.
- Regenerate text: `pdftotext -layout <file>.pdf <file>.txt`.

Copyright © 2024 thinkRF Corporation, all rights reserved. These documents are thinkRF's proprietary
material, reproduced here unmodified for reference; they are not covered by this repository's licence.
Contact thinkRF (support@thinkrf.com) for the official, current versions.
