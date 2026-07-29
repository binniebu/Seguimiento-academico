<?php

namespace Utilities;

class SimplePdf
{
    private array $pages = [];
    private array $lines = [];
    private string $title;
    private int $lineHeight = 15;
    private int $maxLines = 48;

    public function __construct(string $title)
    {
        $this->title = $title;
        $this->addTitle($title);
    }

    public function addTitle(string $text): void
    {
        $this->addLine($text, 16);
        $this->addLine(str_repeat("-", 86), 10);
    }

    public function addSection(string $text): void
    {
        $this->addLine("");
        $this->addLine($text, 13);
        $this->addLine(str_repeat("-", 86), 10);
    }

    public function addLine(string $text = "", int $size = 10): void
    {
        foreach ($this->wrap($text, 95) as $line) {
            if (count($this->lines) >= $this->maxLines) {
                $this->newPage();
            }
            $this->lines[] = ["text" => $line, "size" => $size];
        }
    }

    public function addKeyValue(string $key, string $value): void
    {
        $this->addLine($key . ": " . $value);
    }

    public function addTable(array $headers, array $rows): void
    {
        $this->addLine(implode(" | ", $headers), 9);
        $this->addLine(str_repeat("-", 100), 9);
        foreach ($rows as $row) {
            $this->addLine(implode(" | ", array_map(fn($value) => (string)$value, $row)), 8);
        }
    }

    public function output(string $filename): void
    {
        $this->newPage();
        $pdf = $this->render();
        header("Content-Type: application/pdf");
        header("Content-Disposition: inline; filename=\"" . $filename . "\"");
        header("Content-Length: " . strlen($pdf));
        echo $pdf;
    }

    private function newPage(): void
    {
        if (!empty($this->lines)) {
            $this->pages[] = $this->lines;
            $this->lines = [];
        }
    }

    private function render(): string
    {
        $objects = [];
        $objects[] = "<< /Type /Catalog /Pages 2 0 R >>";
        $kids = [];
        $pageObjectIds = [];
        $contentObjectIds = [];

        $nextId = 3;
        foreach ($this->pages as $page) {
            $pageObjectIds[] = $nextId++;
            $contentObjectIds[] = $nextId++;
        }
        $fontId = $nextId++;

        foreach ($pageObjectIds as $pageId) {
            $kids[] = $pageId . " 0 R";
        }
        $objects[] = "<< /Type /Pages /Kids [" . implode(" ", $kids) . "] /Count " . count($this->pages) . " >>";

        foreach ($this->pages as $idx => $page) {
            $objects[] = "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 {$fontId} 0 R >> >> /Contents {$contentObjectIds[$idx]} 0 R >>";
            $stream = $this->pageStream($page);
            $objects[] = "<< /Length " . strlen($stream) . " >>\nstream\n" . $stream . "\nendstream";
        }

        $objects[] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>";

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
        $y = 750;
        $commands = "BT\n";
        foreach ($page as $line) {
            $commands .= "/F1 " . intval($line["size"]) . " Tf\n";
            $commands .= "1 0 0 1 50 {$y} Tm (" . $this->escape($line["text"]) . ") Tj\n";
            $y -= $this->lineHeight;
        }
        $commands .= "ET";
        return $commands;
    }

    private function escape(string $text): string
    {
        $text = iconv("UTF-8", "Windows-1252//TRANSLIT//IGNORE", $text);
        return str_replace(["\\", "(", ")"], ["\\\\", "\\(", "\\)"], $text);
    }

    private function wrap(string $text, int $width): array
    {
        if ($text === "") {
            return [""];
        }
        return explode("\n", wordwrap($text, $width, "\n", true));
    }
}

?>
