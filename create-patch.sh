print()
{
	echo $log
	echo $log >> $readme_file
}

init()
{
	current_version=${PWD##*/}
	patch_name=Patch_${current_version}_`date +%Y%m%d`
	get_patch_time=`date +%Y-%m-%d,%H:%M:%S`
	git_branch_name=$(git branch | awk '{print $NF}')
	
	kill_files="
	mediatek/build/tools/SignTool/SignTool_MTK
	mediatek/build/tools/SignTool/inc/build_info.h
	mediatek/build/tools/SignTool/lib/SignLib.a
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_adc.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_eint.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_eint_md1.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_gpio_boot.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_gpio_usage.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_kpd.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/cust_power.h
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/pmic_drv.c
	mediatek/custom/yecon82_tb_twn_12_jb5/kernel/dct/dct_MG8392/pmic_drv.h
	mediatek/custom/yecon82_tb_twn_12_jb5/preloader/MTK_Loader_Info.tag
	mediatek/custom/yecon82_tb_twn_12_jb5/preloader/custom_emi.c
	mediatek/custom/yecon82_tb_twn_12_jb5/preloader/inc/custom_emi.h
	mediatek/hardware/camera/common/paramsmgr/feature/custom/custgen.config.ftbl.h
	gen_patch.sh
	make_lcm.sh
	release/
	"
	xxx="
	bootable/bootloader/lk/target/elink8735_ftb_l/dct/dct/codegen.dws
        bootable/bootloader/preloader/custom/elink8735_ftb_l/dct/dct/codegen.dws
        kernel-3.10/drivers/misc/mediatek/mach/mt6735/elink8735_ftb_l/dct/dct/codegen.dws
        vendor/mediatek/proprietary/custom/elink8735_ftb_l/kernel/dct/dct/codegen.dws
"
	modified_tag=modified\:
	deleted_tag=deleted\:
	added_tag=Added\:
	
	mf_tag=MF
	df_tag=DF
	af_tag=AF
	ad_tag=AD
	aa_tag=AA
	
	out_dir=../${patch_name}
	readme_file=$out_dir/Readme.txt
	
	self_name=get_patch_s.sh
	separation="========================================================================================"
	
	if [ -d $out_dir ]; then
		cd $out_dir
		patch_path=$(pwd)
		cd ../${current_version}
		
		#echo $separation
		#echo "Old patch is removing, please wait..."
		#echo "Path: "$patch_path
		rm -rf $out_dir
	fi
	mkdir $out_dir
	cd $out_dir
	patch_path=$(pwd)
	cd ../${current_version}
}

print_patch_info()
{
	log=$separation
	print
	
	log="Patch Name : ${patch_name}"
	print
	
	log="Patch Time : ${get_patch_time}"
	print
	
	log="Git Branch : ${git_branch_name}"
	print
	
	log="Git commit : "
	print
	
	git log -1
	git log -1 >> $readme_file
}

is_kill_file()
{
	for kill_file in $kill_files
	do
		if [ "$file" == "$kill_file" ]; then
			return 0
		fi
	done
	return 1
}

get_patch()
{
	log=$separation
	print
	
	changed_fileinfos=$(git status | awk '{if ($2 =="'$modified_tag'") {print "'$mf_tag'"$3} 
									   else if ($2 =="'$deleted_tag'") {print "'$df_tag'"$3}
									   else if ($2 !="'$modified_tag'" && $2 !="'$deleted_tag'") {print "'$aa_tag'"$2}
									   }')
	for fileinfo in $changed_fileinfos
	do
		tag=${fileinfo:0:2}
		file=${fileinfo:2}
		
		#echo $tag" "$file
		
		if [ "$file" == "" ]; then
			continue
		fi
		
		#kill some out files
		is_kill_file
		if [ "$?" == "0" ]; then
			continue
		fi
		
		if [ "$last_tag" != "" -a "$tag" != "$last_tag" ]; then
			log=
			print
		fi
		
		if [ -f $file -a $tag == "$mf_tag" ]; then
			log="Modified: "$file
			print
			cp --parent $file $out_dir
		elif [ $tag == "$df_tag" ]; then
			log="Deleted: "$file
			print
		elif [ $tag == "$aa_tag" ]; then
			if [ -f $file -a "$file" != "$self_name" ]; then
				log="Added a file: "$file
				print
				cp --parent $file $out_dir
			elif [ -d $file ]; then
				log="Added folder: "$file
				print
				cp -rf --parent $file $out_dir
			fi
		fi
		
		last_tag=$tag
		
	done
}

main()
{
	init
	print_patch_info
	
	echo $separation
	echo "Checking the code, please wait..."
	
	get_patch
	
	echo $separation
	echo "Patch is OK."
	echo "Path: "$patch_path
	echo
}

main
