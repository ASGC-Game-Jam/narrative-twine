# Merge logic for import-from-twine.sh (macOS). Same rules as import-from-twine.ps1 (Windows).
# Usage: LC_ALL=C awk -v out=STAGEDIR -f import-from-twine.awk EXPORT.twee src/a.twee src/b.twee ...
# Writes changed files under STAGEDIR (same relative paths) and prints a report:
#   TOTAL n | UPDATED name<TAB>file | ADDED name | REMOVED name<TAB>file | CHANGED file | WARN text

{
	if (FNR == 1) {
		nf++
		fname[nf] = FILENAME
		if (substr($0, 1, 3) == "\357\273\277") $0 = substr($0, 4)
	}
	sub(/\r$/, "")
	nl[nf]++
	ln[nf, nl[nf]] = $0
}

# Sets HN (unescaped name) and HT (tags, single-spaced). Returns 0 if the line is not a header.
function parse_header(line,    rest, i, c, name, after, end, tagstr, n, parts, k) {
	if (substr(line, 1, 2) != "::") return 0
	rest = substr(line, 3)
	name = ""
	for (i = 1; i <= length(rest); i++) {
		c = substr(rest, i, 1)
		if (c == "\\" && i < length(rest)) { name = name substr(rest, i + 1, 1); i++; continue }
		if (c == "[" || c == "{") break
		name = name c
	}
	gsub(/^[ \t]+|[ \t]+$/, "", name)
	HN = name
	HT = ""
	after = substr(rest, i)
	if (substr(after, 1, 1) == "[") {
		end = index(after, "]")
		if (end > 1) {
			tagstr = substr(after, 2, end - 2)
			gsub(/^[ \t]+|[ \t]+$/, "", tagstr)
			n = split(tagstr, parts, /[ \t]+/)
			for (k = 1; k <= n; k++) if (parts[k] != "") HT = (HT == "" ? parts[k] : HT " " parts[k])
		}
	}
	return 1
}

function has_tag(tags, t) { return index(" " tags " ", " " t " ") > 0 }

function special_key(name, tags) {
	if (name == "StoryData") return "StoryData"
	if (has_tag(tags, "stylesheet")) return "#stylesheet"
	if (has_tag(tags, "script")) return "#script"
	return name
}

# Splits file f into blocks: bh (header), bn (name), bt (tags), bk (key), bb (body), bg (trailing empty lines).
function parse_file(f,    i, j, line, total) {
	total = nl[f]
	# awk drops the final newline; add the empty last line the Windows version sees.
	total++; ln[f, total] = ""
	npre[f] = 0; nb[f] = 0; j = 0
	for (i = 1; i <= total; i++) {
		line = ln[f, i]
		if (parse_header(line)) {
			j = ++nb[f]
			bh[f, j] = line; bn[f, j] = HN; bt[f, j] = HT; bk[f, j] = special_key(HN, HT)
			nbl[f, j] = 0
		} else if (j > 0) {
			nbl[f, j]++; bl[f, j, nbl[f, j]] = line
		} else {
			pre[f, ++npre[f]] = line
		}
	}
	for (j = 1; j <= nb[f]; j++) {
		bg[f, j] = 0
		while (nbl[f, j] > 0 && bl[f, j, nbl[f, j]] == "") { nbl[f, j]--; bg[f, j]++ }
		bb[f, j] = ""
		for (i = 1; i <= nbl[f, j]; i++) bb[f, j] = (i == 1 ? bl[f, j, i] : bb[f, j] "\n" bl[f, j, i])
		hasbody[f, j] = (nbl[f, j] > 0)
	}
}

function emit(s) { if (outn++) outs = outs "\n" s; else outs = s }

function write_file(f, path,    i, m, j, g) {
	outs = ""; outn = 0
	for (i = 1; i <= npre[f]; i++) emit(pre[f, i])
	for (m = 1; m <= kn[f]; m++) {
		j = kidx[f, m]
		emit(bh[f, j])
		if (hasbody[f, j]) emit(bb[f, j])
		for (g = 0; g < bg[f, j]; g++) emit("")
	}
	printf "%s", outs > path
	close(path)
}

END {
	# The export is file 1.
	parse_file(1)
	ne = 0
	for (j = 1; j <= nb[1]; j++) {
		key = bk[1, j]
		if (key == "StoryData") continue
		if (!(key in ej)) {
			ej[key] = j; eorder[++ne] = key; ebody[key] = bb[1, j]; ehas[key] = hasbody[1, j]
		} else if (substr(key, 1, 1) == "#") {
			ebody[key] = ebody[key] "\n\n" bb[1, j]; ehas[key] = 1
		} else {
			print "WARN\tThe export has two passages named '" key "'. Using the last one."
			ej[key] = j; ebody[key] = bb[1, j]; ehas[key] = hasbody[1, j]
		}
	}

	total = 0
	newf = 0
	for (f = 2; f <= nf; f++) {
		parse_file(f)
		if (fname[f] == "src/new-passages.twee") newf = f
		for (j = 1; j <= nb[f]; j++) {
			key = bk[f, j]
			if (key in wf) { print "WARN\t'" key "' is in both " fname[wf[key]] " and " fname[f] ". Only the first is updated."; continue }
			wf[key] = f; wj[key] = j; total++
		}
	}
	print "TOTAL\t" total

	for (f = 2; f <= nf; f++) {
		kn[f] = 0
		for (j = 1; j <= nb[f]; j++) {
			key = bk[f, j]
			if (wf[key] != f || wj[key] != j) { kidx[f, ++kn[f]] = j; continue }
			if (!(key in ej)) {
				# StoryData, StoryTitle, the stylesheet and the script are never removed.
				if (key == "StoryData" || key == "StoryTitle" || substr(key, 1, 1) == "#") { kidx[f, ++kn[f]] = j; continue }
				print "REMOVED\t" key "\t" fname[f]
				if (kn[f] > 0) bg[f, kidx[f, kn[f]]] = bg[f, j]
				changed[f] = 1
				continue
			}
			e = ej[key]
			if (ebody[key] != bb[f, j] || (substr(key, 1, 1) != "#" && bt[1, e] != bt[f, j])) {
				if (substr(key, 1, 1) != "#") { bh[f, j] = bh[1, e]; bt[f, j] = bt[1, e] }
				bb[f, j] = ebody[key]; hasbody[f, j] = ehas[key]
				print "UPDATED\t" bn[f, j] "\t" fname[f]
				changed[f] = 1
			}
			kidx[f, ++kn[f]] = j
		}
	}

	for (i = 1; i <= ne; i++) {
		key = eorder[i]
		if ((key in wf) || substr(key, 1, 1) == "#") continue
		if (newf == 0) { newf = ++nf; fname[newf] = "src/new-passages.twee"; npre[newf] = 0; nb[newf] = 0; kn[newf] = 0 }
		if (kn[newf] > 0 && bg[newf, kidx[newf, kn[newf]]] < 2) bg[newf, kidx[newf, kn[newf]]] = 2
		e = ej[key]
		j = ++nb[newf]
		bh[newf, j] = bh[1, e]; bb[newf, j] = ebody[key]; hasbody[newf, j] = ehas[key]; bg[newf, j] = 1
		kidx[newf, ++kn[newf]] = j
		print "ADDED\t" key
		changed[newf] = 1
	}

	for (f = 2; f <= nf; f++) if (f in changed) { write_file(f, out "/" fname[f]); print "CHANGED\t" fname[f] }
}
