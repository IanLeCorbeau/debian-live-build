# aliasing man to mman, used by mandoc, and piping it to less

manread() {
	/usr/bin/mman "$1" | /usr/bin/less;
}

alias man='manread'
