BEGIN {
    in_paragraph= 0
    in_blockquote= 0
    in_ul= 0
    in_ol= 0
    emitted= 0
}

# Init lookahead
FNR == 1 {
    getline nextline < FILENAME
    getline nextline < FILENAME
}

# Drop setext header marks
/^[=-]+$/ {
    getline
    getline nextline < FILENAME
}

# Escape all ampersands (HTML rule)
/&/ {
    #printf( "R1: %s", $0 )
    gsub(/&/, "\\&amp;", $0)
    #printf( "%30s\n", $0 )
}

# Restore ampersands part of HTML character escape
/&amp;[A-Za-z]{2,4};/ {
    #printf( "R2: %s", $0 )
    gsub(/&amp;/, "\\&", $0)
    #printf( "%30s\n", $0 )
}

# Escape less than (<) (HTML rule)
/</ {
    #printf( "R3: %s", $0 )
    gsub("<", "\\&lt;", $0)
    #printf( "%30s\n", $0 )
}

# line break
/^.*[ ]{2}$/ {
    #$0= sprintf( "%s<br />", $0 )
    sub( /[ ]{2}$/, "<br />", $0 )
}

# block quote
/^>/ {
    if( (! in_blockquote) && (! emitted) ) {
	print "<blockquote><p>"
	in_blockquote= 1
	in_paragraph= 1
    }
    sub(/^>[ ]*/, "", $0)
}

# ATX headers
/^#/ {
    n= match($0, /^#+/)
    header_lvl= RLENGTH
    repl= sprintf("<h%d>", header_lvl)
    sub(/^#+/, repl, $0)

    repl= sprintf("</h%d>", header_lvl)
    if( match($0, /#+$/) )
	sub(/#+$/, repl, $0)
    else
	sub(/$/, repl, $0)
    print
    emitted= 1
}

# unordered list
/^[*+-]/ {
    if( ! in_ul ) {
	print "<ul>"
	in_ul= 1
	in_paragraph= 1
    }
    sub(/^[*+-][ ]*/, "<li>", $0)
    sub(/$/, "</li>", $0)
}

# ordered list
/^[0-9]+[.]/ {
    if( ! in_ol ) {
	print "<ol>"
	in_ol= 1
	in_paragraph= 1
    }
    sub(/^[0-9]+[.][ ]*/, "<li>", $0)
    sub(/$/, "</li>", $0)
}

# empty line
/^$/ {
    if( in_blockquote && (! match(nextline, /^>/)) ) {
	print "</p></blockquote>"
	in_blockquote= 0
	in_paragraph= 0
    }

    if( in_ul ) {
	print "</ul>"
	in_ul= 0
	in_paragraph= 0
    }

    if( in_ol ) {
	print "</ol>"
	in_ol= 0
	in_paragraph= 0
    }

    if( in_paragraph ) {
	print "</p>"
	in_paragraph= 0
    }

}

# paragraph and/or setext header
$0 !~ /^$/ {

    if( match(nextline, /^[=]+$/) ) {
	printf("<h1>%s</h1>\n", $0)
	emitted= 1
    }

    if( match(nextline, /^[-]+$/) ) {
	printf("<h2>%s</h2>\n", $0)
	emitted= 1
    }

    if( (! in_paragraph) && (! emitted) ) {
	print "<p>"
	in_paragraph= 1
    }
}

# Finally: print the line
{ 
    if( ! emitted )
	print
    emitted= 0
    getline nextline < FILENAME
}

END {
    if( in_ul ) {
	print "</ul>"
	in_paragraph= 0
    }

    if( in_ol ) {
	print "</ol>"
	in_paragraph= 0
    }

    if( in_blockquote ) {
	print "</p></blockquote>"
	in_paragraph= 0
    }

    if( in_paragraph )
	print "</p>"
}
