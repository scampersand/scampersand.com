#!/bin/bash

: ${JEKYLL_DEST:=public}

domain=scampersand.com
links=$(grep -Eo "https?://$domain/[^<]*" < $JEKYLL_DEST/sitemap.xml)
declare -A replacements

for l in $links; do
    case $l in
        *://$domain/) continue ;;

        */)
            replacements[$l]=${l%/}  # http://$domain/foo/bar/ => http://$domain/foo/bar
            l=${l#*:}
            replacements[$l]=${l%/}  # //$domain/foo/bar/ => //$domain/foo/bar
            [[ $l == //*/* ]] && l=/${l#//*/}
            replacements[$l]=${l%/}  # /foo/bar/ => /foo/bar
            l=${l%/}; l=${l##*/}/
            replacements[$l]=${l%/}  # bar/ => bar
            ;;

        */index.html)
            replacements[$l]=${l%/index.html}  # http://$domain/foo/bar/index.html => http://$domain/foo/bar
            l=${l#*:}
            replacements[$l]=${l%/index.html}  # //$domain/foo/bar/index.html => //$domain/foo/bar
            [[ $l == //*/* ]] && l=/${l#//*/}
            replacements[$l]=${l%/index.html}  # /foo/bar/index.html => /foo/bar
            l=${l%/index.html}; l=${l##*/}/index.html
            replacements[$l]=${l%/index.html}  # bar/index.html => bar
            ;;

        *.html)
            replacements[$l]=${l%.html}  # http://$domain/foo/bar.html => http://$domain/foo/bar
            l=${l#*:}
            replacements[$l]=${l%.html}  # //$domain/foo/bar.html => //$domain/foo/bar
            [[ $l == //*/* ]] && l=/${l#//*/}
            replacements[$l]=${l%.html}  # /foo/bar.html => /foo/bar
            l=${l##*/}
            replacements[$l]=${l%.html}  # bar.html => bar
            ;;
    esac
done

cmd=''
for k in "${!replacements[@]}"; do
    cmd+="s,href=\"$k\",href=\"${replacements[$k]}\",g;"
    cmd+="s,href=\\(&quot;\\)$k\\1,href=\\1${replacements[$k]}\\1,g;"
    cmd+="s,>$k<,>${replacements[$k]}<,g;"
done
find $JEKYLL_DEST -name '*.html' -o -name '*.xml' -print0 | xargs -0r sed -i -e "$cmd"
