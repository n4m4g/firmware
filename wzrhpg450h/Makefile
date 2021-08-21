firmware:=wzrhpg450h-pro-r30360.enc
#firmware:=wzr_hp_g450h-factory-to-ddwrt.bin
skip_bytes:=208
golden_bytes:=2705 1956
encryptor_name:=buffalo-enc
build_path:=build
encrypt_c:=buffalo-enc.c buffalo-lib.c
encryptor:=$(build_path)/$(encryptor_name)
stripped_firmware:=$(build_path)/$(addprefix stripped-,$(firmware))
decrypted_stripped_firmware:=$(build_path)/$(addprefix decrypted-stripped-,$(firmware))

VPATH:=src/ddwrt:src/openwrt:src/original
vpath %.c src/firmware-mod-kit

check_correctness : $(decrypted_stripped_firmware)
	$(eval first_4_bytes=$(shell xxd $< | head -n1 | cut -c 11-19))
	@echo firmware: $<
	@echo first 4 bytes of image: \ $(first_4_bytes)
	@echo first 4 bytes of golden: $(golden_bytes)
	
$(decrypted_stripped_firmware) : $(encryptor) $(stripped_firmware)
	$< -d -i $(stripped_firmware) -o $@

$(encryptor) : $(encrypt_c)
	gcc -o $@ $^

$(stripped_firmware) : $(firmware)
	dd if=$^ of=$@ bs=$(skip_bytes) skip=1

.PHONY : clean
clean :
	-rm -r build/*

