To generate bordered photos:

```
imagewidth=560
borderpx=220

for x in amy aron; do
    gm convert -geometry $imagewidth -border $borderpx -bordercolor white $x-1000-orig.jpg $x-border-orig.jpg
    gm convert -geometry 1000 $x-border-orig.jpg $x-1000.jpg
    gm convert -geometry 500 $x-border-orig.jpg $x-500.jpg
done
```
