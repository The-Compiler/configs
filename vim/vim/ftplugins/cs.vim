compiler! make
set errorformat=
	\%*[^\"]\"%f\"%*\\D%l:\ %m,
	\\"%f\"%*\\D%l:\ %m,
	\%f(%l\\,%c):\ %trror\ CS%\\d%\\+:\ %m,
	\%f(%l\\,%c):\ %tarning\ CS%\\d%\\+:\ %m,
	\%f:%l:\ %m,
	\\"%f\"\\,\ line\ %l%*\\D%c%*[^\ ]\ %m,
	\%D%*\\a[%*\\d]:\ Entering\ directory\ `%f',
	\%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f',
	\%DMaking\ %*\\a\ in\ %f,
	\%-G%.%#Compilation%.%#,
	\%-G%.%#
