asset:
	cd apps/main/; \
	dart run module_generator:generate_asset apps/main

reset:
	sh clean.sh
	$(MAKE) lang
	$(MAKE) asset
	$(MAKE) gen_main

lang:
	sh gen_localization.sh apps/main

gen_main:
	cd apps/main/; \
	dart run module_generator:generate_build_runner_config; \
	dart run build_runner build --delete-conflicting-outputs

gen:
	@echo "1. Gen apps/main";
	@echo "2. Exit";
	@read -p "Enter your choice: " input; \
	if [ $$input = "1" ]; then \
		$(MAKE) gen_main \
	else \
		echo "Exit"; \
	fi

format:
	dart format .

run_module_generator:
	@echo "Which module? ex: apps/main"
	@read name; \
	sh run_module_generator.sh $$name