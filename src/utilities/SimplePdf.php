<?php

namespace Utilities;

class SimplePdf
{
    private string $title;
    private array $metadata = [];
    private array $sections = [];
    private ?string $currentSection = null;

    public function __construct(string $title)
    {
        $this->title = $title;
    }

    public function addTitle(string $text): void
    {
        // For backward compatibility, but we use $this->title directly.
    }

    public function addKeyValue(string $key, string $value): void
    {
        $this->metadata[$key] = $value;
    }

    public function addSection(string $text): void
    {
        $this->currentSection = $text;
        $this->sections[$text] = [
            'type' => 'text',
            'lines' => [],
            'table' => null
        ];
    }

    public function addLine(string $text = "", int $size = 10): void
    {
        if ($this->currentSection === null) {
            $this->addSection("General");
        }
        $this->sections[$this->currentSection]['lines'][] = $text;
    }

    public function addTable(array $headers, array $rows): void
    {
        if ($this->currentSection === null) {
            $this->addSection("Tabla");
        }
        $this->sections[$this->currentSection]['type'] = 'table';
        $this->sections[$this->currentSection]['table'] = [
            'headers' => $headers,
            'rows' => $rows
        ];
    }

    public function output(string $filename): void
    {
        $pdf = $this->render();
        header("Content-Type: application/pdf; name=\"" . $filename . "\"");
        header("Content-Disposition: inline; filename=\"" . $filename . "\"");
        header("Content-Length: " . strlen($pdf));
        echo $pdf;
    }

    private function render(): string
    {
        $pages = [];
        $pageInstructions = [];

        // 1. Header Banner
        $pageInstructions[] = [
            'type' => 'rect',
            'x' => 40,
            'y' => 715,
            'w' => 532,
            'h' => 45,
            'color' => [26, 54, 93],
            'fill' => true
        ];
        $pageInstructions[] = [
            'type' => 'text',
            'text' => $this->title,
            'x' => 55,
            'y' => 731,
            'size' => 14,
            'color' => [255, 255, 255],
            'font' => '/F2'
        ];

        // 2. Metadata Card (dynamic rows)
        $keys = array_keys($this->metadata);
        $values = array_values($this->metadata);
        $count = count($keys);
        $rowsCount = ceil($count / 2);
        $cardHeight = $rowsCount * 18 + 12;
        $cardY = 700 - $cardHeight;

        $pageInstructions[] = [
            'type' => 'rect',
            'x' => 40,
            'y' => $cardY,
            'w' => 532,
            'h' => $cardHeight,
            'color' => [248, 250, 252],
            'fill' => true
        ];
        $pageInstructions[] = [
            'type' => 'rect',
            'x' => 40,
            'y' => $cardY,
            'w' => 532,
            'h' => $cardHeight,
            'color' => [226, 232, 240],
            'fill' => false
        ];

        for ($i = 0; $i < $count; $i++) {
            $col = $i % 2;
            $row = floor($i / 2);
            $x = $col == 0 ? 55 : 310;
            $yPos = 700 - 15 - ($row * 18);
            
            $key = $keys[$i];
            $val = $values[$i];
            
            $pageInstructions[] = [
                'type' => 'text',
                'text' => $key . ": ",
                'x' => $x,
                'y' => $yPos,
                'size' => 9,
                'color' => [74, 85, 104],
                'font' => '/F2'
            ];
            
            $keyOffset = strlen($key . ": ") * 5.2;
            $pageInstructions[] = [
                'type' => 'text',
                'text' => $val,
                'x' => $x + $keyOffset,
                'y' => $yPos,
                'size' => 9,
                'color' => [26, 32, 44],
                'font' => '/F1'
            ];
        }

        // 3. Sections & Content
        $y = $cardY - 25;
        $pageNum = 1;

        foreach ($this->sections as $secTitle => $sec) {
            // Check if section heading fits (needs at least 50px)
            if ($y < 80) {
                $pages[] = $pageInstructions;
                $pageInstructions = [];
                $pageNum++;
                
                // Draw new page header
                $pageInstructions[] = [
                    'type' => 'rect',
                    'x' => 40,
                    'y' => 740,
                    'w' => 532,
                    'h' => 25,
                    'color' => [26, 54, 93],
                    'fill' => true
                ];
                $pageInstructions[] = [
                    'type' => 'text',
                    'text' => $this->title . " - Página " . $pageNum,
                    'x' => 50,
                    'y' => 748,
                    'size' => 9,
                    'color' => [255, 255, 255],
                    'font' => '/F2'
                ];
                $y = 710;
            }

            // Draw Section Title
            if ($secTitle !== "General" && $secTitle !== "Tabla") {
                $pageInstructions[] = [
                    'type' => 'text',
                    'text' => $secTitle,
                    'x' => 40,
                    'y' => $y,
                    'size' => 11,
                    'color' => [26, 54, 93],
                    'font' => '/F2'
                ];
                $pageInstructions[] = [
                    'type' => 'line',
                    'x1' => 40,
                    'y1' => $y - 4,
                    'x2' => 120,
                    'y2' => $y - 4,
                    'color' => [26, 54, 93],
                    'width' => 1.5
                ];
                $y -= 20;
            }

            if ($sec['type'] === 'text') {
                foreach ($sec['lines'] as $lineText) {
                    if ($y < 50) {
                        $pages[] = $pageInstructions;
                        $pageInstructions = [];
                        $pageNum++;
                        $pageInstructions[] = [
                            'type' => 'rect',
                            'x' => 40,
                            'y' => 740,
                            'w' => 532,
                            'h' => 25,
                            'color' => [26, 54, 93],
                            'fill' => true
                        ];
                        $pageInstructions[] = [
                            'type' => 'text',
                            'text' => $this->title . " - Página " . $pageNum,
                            'x' => 50,
                            'y' => 748,
                            'size' => 9,
                            'color' => [255, 255, 255],
                            'font' => '/F2'
                        ];
                        $y = 710;
                    }
                    $pageInstructions[] = [
                        'type' => 'text',
                        'text' => $lineText,
                        'x' => 40,
                        'y' => $y,
                        'size' => 9,
                        'color' => [45, 55, 72],
                        'font' => '/F1'
                    ];
                    $y -= 14;
                }
            } elseif ($sec['type'] === 'table') {
                $table = $sec['table'];
                $numCols = count($table['headers']);
                
                // Define column widths
                $colWidths = [];
                if ($numCols == 6 && $table['headers'][2] === "Materia") {
                    $colWidths = [80, 50, 230, 30, 40, 102];
                } elseif ($numCols == 8 && $table['headers'][0] === "Cod") {
                    $colWidths = [50, 160, 60, 112, 25, 25, 25, 75];
                } elseif ($numCols == 8 && $table['headers'][0] === "Periodo") {
                    $colWidths = [70, 30, 120, 137, 30, 30, 30, 85];
                } elseif ($numCols == 6 && $table['headers'][0] === "Alumno") {
                    $colWidths = [200, 100, 50, 50, 50, 82];
                } else {
                    $w = floor(532 / $numCols);
                    for ($colIdx = 0; $colIdx < $numCols; $colIdx++) {
                        $colWidths[] = $w;
                    }
                }

                $colX = [];
                $currentX = 40;
                foreach ($colWidths as $w) {
                    $colX[] = $currentX;
                    $currentX += $w;
                }

                // Draw Table Header
                $pageInstructions[] = [
                    'type' => 'rect',
                    'x' => 40,
                    'y' => $y - 18,
                    'w' => 532,
                    'h' => 18,
                    'color' => [237, 242, 249],
                    'fill' => true
                ];
                $pageInstructions[] = [
                    'type' => 'line',
                    'x1' => 40,
                    'y1' => $y - 18,
                    'x2' => 572,
                    'y2' => $y - 18,
                    'color' => [203, 213, 224],
                    'width' => 1
                ];

                for ($colIdx = 0; $colIdx < $numCols; $colIdx++) {
                    $pageInstructions[] = [
                        'type' => 'text',
                        'text' => $table['headers'][$colIdx],
                        'x' => $colX[$colIdx] + 4,
                        'y' => $y - 13,
                        'size' => 8,
                        'color' => [74, 85, 104],
                        'font' => '/F2'
                    ];
                }

                $y -= 18;

                // Draw Table Rows
                foreach ($table['rows'] as $rowIdx => $row) {
                    if ($y < 50) {
                        $pages[] = $pageInstructions;
                        $pageInstructions = [];
                        $pageNum++;
                        $pageInstructions[] = [
                            'type' => 'rect',
                            'x' => 40,
                            'y' => 740,
                            'w' => 532,
                            'h' => 25,
                            'color' => [26, 54, 93],
                            'fill' => true
                        ];
                        $pageInstructions[] = [
                            'type' => 'text',
                            'text' => $this->title . " - Página " . $pageNum,
                            'x' => 50,
                            'y' => 748,
                            'size' => 9,
                            'color' => [255, 255, 255],
                            'font' => '/F2'
                        ];

                        // Redraw Table Header on new page
                        $y = 710;
                        $pageInstructions[] = [
                            'type' => 'rect',
                            'x' => 40,
                            'y' => $y - 18,
                            'w' => 532,
                            'h' => 18,
                            'color' => [237, 242, 249],
                            'fill' => true
                        ];
                        $pageInstructions[] = [
                            'type' => 'line',
                            'x1' => 40,
                            'y1' => $y - 18,
                            'x2' => 572,
                            'y2' => $y - 18,
                            'color' => [203, 213, 224],
                            'width' => 1
                        ];
                        for ($colIdx = 0; $colIdx < $numCols; $colIdx++) {
                            $pageInstructions[] = [
                                'type' => 'text',
                                'text' => $table['headers'][$colIdx],
                                'x' => $colX[$colIdx] + 4,
                                'y' => $y - 13,
                                'size' => 8,
                                'color' => [74, 85, 104],
                                'font' => '/F2'
                            ];
                        }
                        $y -= 18;
                    }

                    // Zebra striping
                    if ($rowIdx % 2 == 0) {
                        $pageInstructions[] = [
                            'type' => 'rect',
                            'x' => 40,
                            'y' => $y - 18,
                            'w' => 532,
                            'h' => 18,
                            'color' => [250, 252, 254],
                            'fill' => true
                        ];
                    }

                    // Bottom border of row
                    $pageInstructions[] = [
                        'type' => 'line',
                        'x1' => 40,
                        'y1' => $y - 18,
                        'x2' => 572,
                        'y2' => $y - 18,
                        'color' => [241, 245, 249],
                        'width' => 0.5
                    ];

                    for ($colIdx = 0; $colIdx < $numCols; $colIdx++) {
                        $cellVal = (string)($row[$colIdx] ?? '');
                        $availWidth = $colWidths[$colIdx] - 8;
                        if ($this->getStringWidth($cellVal, 8) > $availWidth) {
                            while (strlen($cellVal) > 0 && ($this->getStringWidth($cellVal . "...", 8) > $availWidth)) {
                                $cellVal = substr($cellVal, 0, -1);
                            }
                            $cellVal .= "...";
                        }

                        $pageInstructions[] = [
                            'type' => 'text',
                            'text' => $cellVal,
                            'x' => $colX[$colIdx] + 4,
                            'y' => $y - 13,
                            'size' => 8,
                            'color' => [45, 55, 72],
                            'font' => '/F1'
                        ];
                    }
                    $y -= 18;
                }
                $y -= 10;
            }
        }

        if (!empty($pageInstructions)) {
            $pages[] = $pageInstructions;
        }

        // Draw PDF Catalog structure
        $objects = [];
        $objects[] = "<< /Type /Catalog /Pages 2 0 R >>";
        $kids = [];
        $pageObjectIds = [];
        $contentObjectIds = [];

        $nextId = 3;
        foreach ($pages as $p) {
            $pageObjectIds[] = $nextId++;
            $contentObjectIds[] = $nextId++;
        }
        $f1Id = $nextId++; // Helvetica
        $f2Id = $nextId++; // Helvetica-Bold
        $f3Id = $nextId++; // Courier

        foreach ($pageObjectIds as $pageId) {
            $kids[] = $pageId . " 0 R";
        }
        $objects[] = "<< /Type /Pages /Kids [" . implode(" ", $kids) . "] /Count " . count($pages) . " >>";

        foreach ($pages as $idx => $p) {
            $objects[] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 {$f1Id} 0 R /F2 {$f2Id} 0 R /F3 {$f3Id} 0 R >> >> /Contents {$contentObjectIds[$idx]} 0 R >>";
            $stream = $this->pageStream($p);
            $objects[] = "<< /Length " . strlen($stream) . " >>\nstream\n" . $stream . "\nendstream";
        }

        $objects[] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>";
        $objects[] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>";
        $objects[] = "<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>";

        $pdf = "%PDF-1.4\n";
        $offsets = [0];
        foreach ($objects as $i => $obj) {
            $offsets[] = strlen($pdf);
            $pdf .= ($i + 1) . " 0 obj\n" . $obj . "\nendobj\n";
        }

        $xref = strlen($pdf);
        $pdf .= "xref\n0 " . (count($objects) + 1) . "\n";
        $pdf .= "0000000000 65535 f \n";
        for ($i = 1; $i <= count($objects); $i++) {
            $pdf .= sprintf("%010d 00000 n \n", $offsets[$i]);
        }
        $pdf .= "trailer\n<< /Size " . (count($objects) + 1) . " /Root 1 0 R >>\n";
        $pdf .= "startxref\n{$xref}\n%%EOF";
        return $pdf;
    }

    private function pageStream(array $page): string
    {
        $commands = "";
        
        // 1. Draw Graphics first (rectangles, lines)
        foreach ($page as $inst) {
            if ($inst['type'] === 'rect') {
                $r = $inst['color'][0] / 255;
                $g = $inst['color'][1] / 255;
                $b = $inst['color'][2] / 255;
                $op = $inst['fill'] ? 'f' : 'S';
                $commands .= sprintf("%.3f %.3f %.3f %s\n", $r, $g, $b, $inst['fill'] ? 'rg' : 'RG');
                $commands .= sprintf("%.2f %.2f %.2f %.2f re %s\n", $inst['x'], $inst['y'], $inst['w'], $inst['h'], $op);
            } elseif ($inst['type'] === 'line') {
                $r = $inst['color'][0] / 255;
                $g = $inst['color'][1] / 255;
                $b = $inst['color'][2] / 255;
                $commands .= sprintf("%.3f %.3f %.3f RG\n", $r, $g, $b);
                $commands .= sprintf("%.2f w\n", $inst['width']);
                $commands .= sprintf("%.2f %.2f m %.2f %.2f l S\n", $inst['x1'], $inst['y1'], $inst['x2'], $inst['y2']);
            }
        }
        
        // 2. Draw Text on top
        $commands .= "BT\n";
        foreach ($page as $inst) {
            if ($inst['type'] === 'text') {
                $r = $inst['color'][0] / 255;
                $g = $inst['color'][1] / 255;
                $b = $inst['color'][2] / 255;
                $commands .= sprintf("%.3f %.3f %.3f rg\n", $r, $g, $b);
                $commands .= sprintf("%s %d Tf\n", $inst['font'], intval($inst['size']));
                $commands .= sprintf("1 0 0 1 %.2f %.2f Tm (%s) Tj\n", $inst['x'], $inst['y'], $this->escape($inst['text']));
            }
        }
        $commands .= "ET";
        return $commands;
    }

    private function escape(string $text): string
    {
        $text = iconv("UTF-8", "Windows-1252//TRANSLIT//IGNORE", $text);
        return str_replace(["\\", "(", ")"], ["\\\\", "\\(", "\\)"], $text);
    }

    private function getStringWidth(string $text, int $fontSize): float
    {
        $widths = [
            ' ' => 278, '!' => 278, '"' => 355, '#' => 556, '$' => 556, '%' => 889, '&' => 667, '\'' => 191,
            '(' => 333, ')' => 333, '*' => 389, '+' => 584, ',' => 278, '-' => 333, '.' => 278, '/' => 278,
            '0' => 556, '1' => 556, '2' => 556, '3' => 556, '4' => 556, '5' => 556, '6' => 556, '7' => 556,
            '8' => 556, '9' => 556, ':' => 278, ';' => 278, '<' => 584, '=' => 584, '>' => 584, '?' => 556,
            '@' => 1015, 'A' => 667, 'B' => 667, 'C' => 722, 'D' => 722, 'E' => 667, 'F' => 611, 'G' => 778,
            'H' => 722, 'I' => 278, 'J' => 500, 'K' => 667, 'L' => 556, 'M' => 833, 'N' => 722, 'O' => 778,
            'P' => 667, 'Q' => 778, 'R' => 722, 'S' => 667, 'T' => 611, 'U' => 722, 'V' => 667, 'W' => 944,
            'X' => 667, 'Y' => 667, 'Z' => 611, '[' => 278, '\\' => 278, ']' => 278, '^' => 484, '_' => 556,
            '`' => 278, 'a' => 556, 'b' => 556, 'c' => 500, 'd' => 556, 'e' => 556, 'f' => 278, 'g' => 556,
            'h' => 556, 'i' => 222, 'j' => 222, 'k' => 500, 'l' => 222, 'm' => 833, 'n' => 556, 'o' => 556,
            'p' => 556, 'q' => 556, 'r' => 333, 's' => 500, 't' => 278, 'u' => 556, 'v' => 500, 'w' => 722,
            'x' => 500, 'y' => 500, 'z' => 500, '{' => 394, '|' => 222, '}' => 394, '~' => 584
        ];

        $width = 0;
        $len = strlen($text);
        for ($i = 0; $i < $len; $i++) {
            $char = $text[$i];
            $charWidth = $widths[$char] ?? 500;
            $width += ($charWidth / 1000) * $fontSize;
        }
        return $width;
    }
}
