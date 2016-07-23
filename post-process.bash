#!/bin/bash

links=$(grep -Eo 'https?://scampersand\.com/[^<]*' < public/sitemap.xml)
declare -A replacements

for l in $links; do
    case $l in
        *://scampersand.com/) continue ;;

        */)
            replacements[$l]=${l%/}
            l=${l#*:}
            replacements[$l]=${l%/}
            l=/${l#//*/}
            replacements[$l]=${l%/}
            l=${l%/}; l=${l##*/}/
            replacements[$l]=${l%/}
            ;;

        */index.html)
            replacements[$l]=${l%/index.html}
            l=${l#*:}
            replacements[$l]=${l%/index.html}
            l=${l#//*}
            replacements[$l]=${l%/index.html}
            l=${l%/index.html}; l=${l##*/}/index.html
            replacements[$l]=${l%/index.html}
            ;;

        *.html)
            replacements[$l]=${l%.html}
            l=${l#*:}
            replacements[$l]=${l%.html}
            l=${l#//*}
            replacements[$l]=${l%.html}
            l=${l##*/}
            replacements[$l]=${l%.html}
            ;;
    esac
done

cmd=''
for k in "${!replacements[@]}"; do
    cmd+="s,href=\"$k\",href=\"${replacements[$k]}\",g;"
done

find public -name \*.html -print0 | xargs -0r sed -i -e "$cmd"

sed -i -re '/scampersand.com\/[^<]/s/(\.html|\/)</</' public/sitemap.xml
