--[[
--文件操作
--CLJ
--2014-7-15
--]]

FileOperate = {}
local p = FileOperate;

--文件的路径 res下面的
--获取2222.tet文件具体路径
--GameResPath("2222.txt");

--删除文件
function p:RemoveFile(str)
	os.remove (str);
end

--[[
写入字符串到文件中
fileName	文件名
writeMode	写入格式
r 打开只读文件，该文件必须存在。
r+ 打开可读写的文件，该文件必须存在。
w 打开只写文件，若文件存在则文件长度清为0，即该文件内容会消失。若文件不存在则建立该文件。
w+ 打开可读写文件，若文件存在则文件长度清为零，即该文件内容会消失。若文件不存在则建立该文件。
a 以附加的方式打开只写文件。若文件不存在，则会建立该文件，如果文件存在，写入的数据会被加到文件尾，即文件原先的内容会被保留。
a+ 以附加方式打开可读写的文件。若文件不存在，则会建立该文件，如果文件存在，写入的数据会被加到文件尾后，即文件原先的内容会被保留。
--]]
--writeStr	写入字符串
function p:WriteToFile(fileName, writeMode, writeStr)
	local file = io.open(fileName, writeMode);
	if file ~= nil then
		file:write(tostring(writeStr));
		file:close()
	end
end

--[[
readMode = "r"
readParam
*n - 读取一个数字并返回它。例：file.read("*n")
*a - 从当前位置读取整个文件。例：file.read("*a")
*l - (默认) - 读取下一行，在文件尾 (EOF) 处返回 nil。例：file.read("*l")
--]]
function p:ReadFromFile(fileName, readMode, readParam)
	local getStr = nil;
	local file = io.open(fileName, readMode);
	if file ~= nil then
		getStr = file:read(readParam);
		file:close()
	else
		cclog("------Lua Open File Faild");
	end
--[[
在成功打开file后使用
for l in file:lines() do
  print(l)
end
--]]
	return getStr;
end


--IsFileExistEx
--[[
	local str = GameResPath("2222.txt");
	FileOperate.WriteToFile(str, "a+", "HeaderId\n");
	
	local strShow = FileOperate.ReadFromFile(str, "r", "*a");
	print(strShow);
--]]

