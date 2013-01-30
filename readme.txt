

Instructions:

1) Please make sure that src\siftWin32.txt is renamed to src\siftWin32.exe. Please run this code on a CAEN machine.
2) Please copy the code to the local drive (C:\) or to \\storage.adsroot.itcs.umich.edu\home which is usually mapped as directory (N:\) on eecs machine. 
   This is required because, the project uses a sift executable and Windows has a security policy restriction that disallows execution of the exe on the linux (\\afs\umich.edu\user) network drive by a child process. 
3) In matlab, please do these steps.
	Parallel -> Manage Cluster Profiles -> Edit (on local cluster profile which is the default).
	Set 'Number of workers to start on your local machine.' to 8. 
4) Please close all other programs and run demo.m
5) The panorama images will be within the test cases in the Demos directory. 
