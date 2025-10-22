b1_s_title: db "WELCOME TO THE JAIDEOS BOOTLOADER (v0.02)", 10, 0
b1_s_welcome: db "hi marko!", 10, 10, 0

b1_s_memory: db "conventional memory (kb): ", 0
b1_s_low_memory: db "extended memory between 1m and 16m (kb): ", 0
b1_s_high_memory: db "64k blocks of extended memory above 16m: ", 0
b1_s_set_video: db "setting video mode... ", 0
b1_s_video_info: db "current video mode: 720x400px (80x25ch) 16 color VGA", 0
b1_s_load_gdt: db "loading global descriptor table... ", 0

b1_s_navbar_text: db "[ LOAD KERNEL ]   [ RESTART ]   [ PANIC ]   [ DO NOTHING ]", 0
b1_s_load_finished: db 10, "press ENTER to boot or use the arrow keys to select another action. ", 0

b1_s_loading_kernel: db "loading kernel into 0x00010000... ", 0
b1_s_enabling_a20: db "checking and enabling a20... ", 0
b1_s_protected: db "entering 32-bit protected mode...", 0

b1_s_success: db "OK", 10, 0
b1_s_panic: db "PANIC: bootloader failure", 10, "everything has gone terribly wrong", 10, 10, "this computer will automatically reboot in 5 seconds.", 10, 0

b1_s_nothing: db "$$$$$$$$$1|JUJUJZkb$$$$ 1{{{}{QLLLC/]]?????----_-_-_-_-_    $$$$WzzXc|1)1$$$$$$",10,"$$$$$(|1]UUUUUqM$$$   [}[}[CCCCCJJJ[?----_-_--_-_-_-_____+      $$$$$cv{))1)1$$",10,"%((|(|nYUYUd$$$$    [][]][CJJJUUUJ?UU}__+++++++++++++++++++          $$$$$C1)1)",10,"(||1YYY%$$$m      ]]??---XJUUUUU__+_+++++++++++++_+++++++++++              L@$$",10,"X$$$$$$        ]?---_--_--+__+++++++++_++_++_++_++++!+++_++_++              $$1",10,"zXY$       --_-_-_--_-___ ++++++++++_++_++++++++++++++~+++++++++           $J)1",10,"zXzX&$    -+________+_+_++++++_++_++++~+++++++?++++_+++ ++++++++++       a$czzz",10,"()}zzX$$     +_+++++++ +++_++++++++++ ++++_++_~++_++++++~__++_+_+++++++ Bpzzccz",10,")))))))r$        _++<~+++++++_+++++_++++_+++++v++++++++_++~+++++++++  $$ccczzzc",10,")(())((zzz$        +++++_+++++++_+++<+_++++++ \      ++++++'+++     d$vcvcczcc(",10,"$$)}zzzzczzc$    ; ++_++++++++++_+nu++~++++++vv$$$ur!>>>>~++++++  $hccccctczc11",10,"$(zzzzczzccnrn$ +~+++++~ilI;;!Itr>$$+v++++_+vv$$$$B8k:}} li~__>++~ M$mvvvcccczf",10,"vczXczzzzn)f$?+~++++++<l       &${$r[$+++++~c$Q$$        ';>~++++++ $wfnuccvtzz",10,"zzzzY$$$Qz$_'++++- >_++I,  $X)1    n$$++++ u$$ c   $$$/ `;ll++_+++++++$$xccczzc",10,"zXz$$$$$$!+++++++++++:+il: +$$$)     /_++ n$B     o$$$ '^I> i<+++++++ $$8cccczz",10,"$$$$$$$$) _++++~+_   ++'<}?>z$$$  $  $;+iw$$$  f $$$~,:,~+_~.$$$$Zrjtnvvv$$$$$$",10,"$$$$$$$$$$$$$$$$$$$-++++++  l 8MW$$$$$$ O$$$$$$$$$%W$$$-+++++<$$$BB(vcccczW$$$$",10,"$$$$$$$$$$$$$$$$$$+++++_$+++$$$$$$$$$$$$$$$$$$$$$$$$$$~++ +++++$$$Z\cvucczzc$$$",10,"$$dzY$$$$$$$$$$u$+++`$$$+++++M$$$$$$$$$$$$$$?$$$$$$$v `+ ++$ _++_;Ucc(c@nzcczn$",10,"$$$$$$$$$$$$ac$! 11$$$$[+;+++  $$$$$$$$$$$$$$$$$$$$   _~+++,$$$))$$$cvzc$$$$$$$",10,"$$$$$$$$$]fXzzzz|\||($$++ +_+     $$$$$$$$$$$$$$      +++I bmC(|$$$$$$$$$$$$$$$",10,"$$$$$$@$$$$$zzzz$$Q__$$$$++++        $$$$$$$$       $$++++$$$$$$$$$$$$$$$$@$$$$",10,"$$$$$$$$$$$\zczz(~$$$$$$$++++  $$v   'vuv ucv    u$$  ++++$$$$$$$h$$$$$$$$$$$$$",10,"$$Q$$$$$$$$fzzcz]$$$$$$$$++_++8$$$<  |          $$$$$++_++0$$$$$${[$$$X$$$$$$$$",10,"m0)001$$$$$fczzz l\$$$$$$+++++$$$$$$          <$$$$$$+++++ $$$$$/t  tff$$$$$[0J",0
