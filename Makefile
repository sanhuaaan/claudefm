PREFIX     ?= $(HOME)/.local
BINDIR     ?= $(PREFIX)/bin
CONFIG_DIR ?= $(HOME)/.config/claudefm

.PHONY: install uninstall check help

help:
	@echo "claudefm — CLI player for the claudeFM YouTube radio"
	@echo
	@echo "Targets:"
	@echo "  make install     Copy claudefm to \$$(BINDIR) and seed config at \$$(CONFIG_DIR)/url"
	@echo "  make uninstall   Remove the installed binary (config left untouched)"
	@echo "  make check       Verify mpv and yt-dlp are available"
	@echo
	@echo "Variables (override on the command line):"
	@echo "  PREFIX     = $(PREFIX)"
	@echo "  BINDIR     = $(BINDIR)"
	@echo "  CONFIG_DIR = $(CONFIG_DIR)"

install:
	install -d $(BINDIR)
	install -m 755 claudefm $(BINDIR)/claudefm
	install -d $(CONFIG_DIR)
	@if [ -f $(CONFIG_DIR)/url ]; then \
		echo "✓ keeping existing config at $(CONFIG_DIR)/url"; \
	else \
		install -m 644 .claudefm.url $(CONFIG_DIR)/url; \
		echo "✓ seeded default config at $(CONFIG_DIR)/url"; \
	fi
	@if [ -f $(CONFIG_DIR)/input.conf ]; then \
		echo "✓ keeping existing input.conf at $(CONFIG_DIR)/input.conf"; \
	else \
		install -m 644 input.conf $(CONFIG_DIR)/input.conf; \
		echo "✓ seeded input.conf at $(CONFIG_DIR)/input.conf"; \
	fi
	install -m 644 stats.lua $(CONFIG_DIR)/stats.lua
	@echo "✓ installed stats.lua to $(CONFIG_DIR)/stats.lua"
	@echo "✓ installed claudefm to $(BINDIR)/claudefm"
	@case ":$$PATH:" in \
		*":$(BINDIR):"*) ;; \
		*) echo "⚠  $(BINDIR) is not in your PATH. Add this to your shell config:"; \
		   echo "    export PATH=\"$(BINDIR):\$$PATH\"" ;; \
	esac

uninstall:
	rm -f $(BINDIR)/claudefm
	@echo "✓ removed $(BINDIR)/claudefm"
	@echo "  config left at $(CONFIG_DIR)/ — delete manually if you want"

check:
	@command -v mpv    >/dev/null 2>&1 || { echo "✗ missing: mpv";    exit 1; }
	@command -v yt-dlp >/dev/null 2>&1 || { echo "✗ missing: yt-dlp"; exit 1; }
	@echo "✓ mpv and yt-dlp are installed"
