% MATLAB Tutorial
% - Emily Wasserman

% How to use this tutorial:
% I highly recommend going through in order.
% When you encounter code, you can just copy and paste it into your
% Matlab terminal to run it, or use a keyboard shortcut to run it.

% 0): Setting Up
	% a. Getting MATLAB
	% b. Setting up
	% c. Text editors
% 1): The Basics
	% a. Navigating
	% b. Data types
	% c. Built-in functions
	% d. Logical operators
	% e. Flow
% 2): Functions
	% a. Function definitions
	% b. Function workspaces
% 3): Debugging
	% a. Stack traces
	% b. Common errors
	% c. What to do
	% d. Debug mode

% 0. SETTING UP

% a. Getting a copy of MATLAB

% There are ways to get a bootleg copy of MATLAB off the Internet, but the
% legit way to do it is to download it from mathworks.com.
% The lab server has both Matlab2012b and 2015a, and most scripts are
% written for either 2012b + SPM8 or 2015a + SPM12. Pleiades has
% these versions and more.
% Contact me (Emily) to set up an academic-license account on your computer.

% b. Setting up MATLAB

% i. Paths
% When you first install it, MATLAB will create a new folder called MATLAB
% somewhere on your computer. Mine is in /Users/[my username]/Documents,
% while the ones on the server are usually in /home/[username].

% This is a folder that is automatically added to the top of Matlab's search
% path when it opens. The search path is a list of all the directories on 
% the computer that Matlab can access while it's running. When you ask
% Matlab for something (for example, when you call a script), Matlab will
% look through the search path in order from top to bottom. This means if 
% something isn't in the search path, Matlab will not be able to find it - 
% and if there are two identically named files, Matlab will give you the one
% it finds first (= the one closer to the top of the search path).

% The easiest way to add paths is to hit "Set Path", up in the "Home" menu
% of your Matlab window. 
% From the Matlab terminal, you can also use the commands addpath(), genpath(),
% and rmpath(). 
% When you add a path this way, it is automatically moved to the top of the
% overall search path. So for example, if the path to SPM8 is already in your
% Matlab search path, and then you add the path to SPM12, Matlab will source files
% in SPM12 by default.

% ii. Matlab's Layout
% Matlab's window is basically five boxes: 1. a menu (top); 2. the directory
% bar (right under it); 3. the file menu (left); 4. the workspace (right);
% and 5. the terminal (center). The editor window will also appear at center top
% if you are editing a script.

% The only two menus you need to worry about are the "Home" and "Editor" menus.
% "Editor" won't appear unless you have a script open for editing. 

% The directory bar is a quick interactive way to change the directory you're in,
% while the file menu on the left will show you all the files you have in that
% directory (and others, if you want).

% Why does the directory you're in (= the current working directory) matter?
% As I said before, Matlab can only access things in its search path. But it can
% also access anything in its current working directory, and often it's easier
% to just move into the directory you want when you want it, rather than adding
% *every* directory you might possibly ever want into your search path.
% Some commands also depend on your current working directory. For example, the 
% dir() command looks for files in your working directory by default, so if 
% you're looking for files somewhere else, you need to specify the full path.
% E.g. dir('*.mat') will look for all the .mat files in my current working directory.
% If I want to look for them elsewhere, I'll need something like dir('~/Documents/*.mat').

% The file menu...is a file menu. You can double-click .m files from it to open them
% in the editor, or .mat files to load them into your workspace.

% If your file system is long-term memory, your workspace is your working memory:
% it holds all the variables you are currently manipulating within Matlab. 
% The workspace menu on the right shows you everything that's in your workspace,
% including its name, size, data type, and value. Double-click any of them to 
% view them in a worksheet. You can get something into your workspace by a. 
% creating it (via a script, or the terminal) or b. loading it from a
% previously saved .mat file. 

% There's also a more abstract idea of a workspace as an area that 
% some program has access to. (The basic concept here is called 'scope'.)
% This becomes relevant when, for example, you define functions (see 2.).
% Most CS people I've met use 'knowledge' as a metaphor for scope;
% for example, Matlab "knows about" everything in its workspace, but a Matlab function
% doesn't "know about" those things by default - so you have to "tell it" about
% those things by passing them as arguments to the function.

% The terminal, like a BASH shell or something similar, is just a command line.
% A line where you type commands. If you leave the semicolon off the end of
% a command, the terminal will also display the output of the command.

% What's a command? It's exactly what it sounds like. You are telling Matlab
% to do something.
% For example, if you type a = 1 into the terminal, what you are really doing
% is telling Matlab, "Hey, mark out some space in my computer, put a 1 there,
% and then match it to the name 'a'." 
% If you type my_function(), you are telling it, "Go find a file somewhere that's
% named my_function.m, and run the function I defined inside it."

% Thus, we can think of a script as a written set of instructions. Matlab won't
% actually do any of them until you tell it to follow your instructions - that is,
% until you run the script. 
% But if you write your commands in the terminal, Matlab will just go ahead and
% run them right away.

% c. Text editors

% Matlab has a built-in text editor. You can open it by hitting "New Script" on the 
% Home Menu, or you can type 
% >> edit [name of your script]
% in the terminal. 
% I personally prefer to edit in Sublime Text, which will do nice things like
% autocomplete variable names for you. You can download it at http://www.sublimetext.com/.


% 1. THE BASICS

% a. Navigating 

% Welcome to Matlab! Let's figure out how to get around :)
% Matlab's environment is your computer, and a key part of
% using it effectively is knowing where you are and how to
% get elsewhere inside the computer.

% Don't worry about what exactly we are doing yet.
% You can intuitively figure out the important bits just by
% taking a look at these examples.
% We'll think about data types, syntax, etc. in the next section.

pwd
previous_dir = pwd; % make a variable to hold our current working dir
cd /; % navigate to a new directory (the computer's root dir)
pwd % tell us where we are

disp(previous_dir);
cd previous_dir; % <- this doesn't work! but the following does:
cd(previous_dir);
ls % list everything in this directory

myname = 'wass'; % change this to your username
cd(fullfile('/Users',myname,'Documents','MATLAB'));
% fullfile() makes a file path out of the strings you give it
matlab_dir = 'MAT';
cd(fullfile('/Users',myname,'Documents',[matlab_dir 'LAB']));
% basically the same thing, except we smushed two strings
% into one using [] brackets 

cd(previous_dir);
dir
all_files = dir(fullfile('/Users',myname,'Documents')); 
% all_files is a structure of all the files in Documents
only_pdfs = dir(fullfile('/Users',myname,'Documents','*.pdf'));
only_pdfs(1).name
% the name field of the structure gives you filenames

cd(fullfile('/Users',myname,'Documents'));
subdirectory = 'newdir';
isdir(subdirectory)) % check if this subdirectory already exists
mkdir(subdirectory); 
isdir(subdirectory) % check again
rmdir(subdirectory); % remove the new subdirectory

% These assume you have a Mac with Documents and Downloads
% under your username (i.e. their default structure).
cd(fullfile('/Users',myname,'Documents'));
movefile([pwd '/' only_pdfs(1).name],['/Users/' myname '/Downloads']);
cd(fullfile('/Users',myname,'Downloads'))
copyfile([pwd '/' only_pdfs(1).name],'../Documents');
delete(only_pdfs(1).name)

clear only_pdfs all_files subdirectory matlab_dir

% b. Data types

% i. Things (Numbers, Characters, Booleans)

% I like to think of variables and objects as actual things. 
% I visualize them kind of like a giant box of toys with different shapes.
 % If programming seems annoyingly abstract at first, just try imagining everything
% as physical objects - it's way more intuitive!

% There are, roughly, three basic kinds of thing we use:
% numbers, characters, and booleans.

number=3
% Pretty self-evident.
character='a'
% Don't forget the quotes!
boolean=true
% A boolean takes on the logical value of true or false.
% You need these because you will eventually want Matlab
% to tell you whether something *is* true or false. But it
% can't just give you the word 'true' - because Matlab is
% stupid, and thinks the word 'true' is just another word,
% when we really want it to take on the VALUE of true.

% I could have just typed 3, 'a', or true into the terminal. 
% What happens when you do?
3
% Look at your workspace on the right side. You should see a 
% variable called 'ans'.
% If you just pass a thing into the terminal, Matlab automatically
% assigns that thing to the variable 'ans', for 'answer'. I.e., it acts
% as if you've given it a command to make that thing, and gives you
% a handy way to find the thing again - its variable name.
% But be aware - Matlab has no compunctions about overwriting 'ans'
% the next time you do this, so you will lose the previous thing.

% Pro tip: make everything a variable, always. 
% You do this by using the = sign, as above. 

% But there's something weird here. In the workspace, the name 'boolean'
% seems to be matched up to a value of 1, instead of true. What??
% Surprise! Matlab secretly represents booleans as numbers. 1 is true
% and 0 is false. 

% We can check the type of our things with these handy built-in functions:
isnumeric(number)
ischar(character)

% You'll notice that the terminal spits out a 1 for both of these.
% There's those number-booleans again, telling us that
% in fact number is numeric, and character, a character array.

% ii. Sets of things (Arrays, Strings, Cell Arrays, Matrices, Structures)

% If this is what we can do with things, imagine what we can do with...
% multiple things put together! Incredible!!

new_array=[1 2 3 4 5]
% We can put a bunch of numbers inside brackets and treat the entire
% set as a single thing.
new_string='i am a string'
% Similarly, we can put a bunch of characters inside quotes and treat
% the entire thing as one word or sentence.
% Since whitespaces are characters too, Matlab thinks of words and sentences
% as the same thing - strings of characters. 
vertical_array=[1; 2; 3; 4; 5]
% We can also flip arrays. In fact, we can do much more...
new_matrix=[1 2; 3 4; 5 6]
% We can make a multidimensional array - a matrix! 
% White spaces separate items on the same row, while semicolons show where
% to split rows.

new_cell=cell(2,5)
new_cell_2={'cat' 2}
% I think of cell arrays like labeled file drawers.
% Each cell is a container that holds a thing, and 
% you can get those things out again if you know the labels.
new_cell_2{1}
% new_cell and new_cell_2 are both cell arrays. new_cell is
% empty - all we've done is use the cell() function to tell
% Matlab we want to make a cell array.
% new_cell_2 has contents. Since we put these contents in curly
% brackets, Matlab knows we want to construct a cell array,
% even without using the cell() function.

new_structure = struct('field1',[1 2 3],'field2','meow')
new_structure.field2
% Similarly, a structure can be thought of as a bunch of containers
% that hold things.
% The difference is that you find things with a word label, rather
% than with numbers. These labels are called fields.
new_structure.field2.subfield = rand;
new_structure.field2
new_structure
% Fields can also have fields. You can think of it as a hierarchy.
% The structure itself is the top level, its fields are the next level down,
% their fields the next level, and so on. 

% As you can see with new_structure, adding a field to a field makes the first
% field a structure.
% You can, in fact, just build structures this way, without even using the struct()
% function.
another_structure.field1 = 'hello'
% Since you used . to make a field, Matlab knows you want to create a structure
% called another_structure and makes one for you.

% Importantly, structures also have a size.
% For example, the dir() command actually gives you a structure
% containing information about files in your directory,
% where n = length(dir_structure) = number of files.
previous_dir = pwd;
cd(fullfile('/Users',myname,'Documents'));
dir_structure = dir('*pdf'); % find all the pdf files here
L = length(dir_structure);
disp(dir_structure(L).name); % display the name of the last file
cd(previous_dir);

% iii. Symbols/operators

% Ok, so symbols aren't really a data type. But it's good to cover them
% here anyway. Here's a cheat sheet:

% *: your wildcard operator. It can stand in for anything.
% Super useful for finding lots of files, and when you don't
% know exactly what you're looking for.
dir('*.m')
% Find all .m files in our current directory.
dir(['/Users/' myname '/Documents/*'])
% Find everything in the Documents folder.
dir('*f*.mat')
% Find all .mat files that have an f somewhere in their name.

% .: index into a structure.
Emily.name.first = 'Emily';
Emily.name.last = 'Wasserman';

% ,: separate pieces of information.
A=randn(5,1);B=randn(5,1);[r,p]=corrcoef(A,B)
% ^make two 5x1 vectors of random numbers and find their correlation
C=cell{5,1};size(C)

% (): grab indexed elements.
A(1) % first item in A
A(3,1) % item in the third row, first column of A
A(5,5) % A is only 5x1, so there's nothing in position (5,5)

% Let's try with a cell array...
subjects = {'subject_1' 'subject_2'};
mkdir(subjects(1))
% Why doesn't this work?!
sub1_curve=subjects(1)
sub1_curly=subjects{1}
% The parentheses () grabbed us the first CELL in the 
% cell array, not the string inside the cell.

% {}: grab value from within a cell.

subjects(1)='new_subject';
% Now we know why this fails. 
% We tried to take a cell and make it into a string,
% when what we really wanted to do is get the string
% inside the cell and swap it with another string.
subjects{1} = 'new_subject';

% :: grab every indexed value along this dimension.
A=randn(5) % 5x5 array of random numbers
A(1,:) %grab every value in row 1
A(:,1) %grab every value in column 1

% %: comment out a line.
% As you can probably tell, this works whether you put the 
% comment on its own line or not.
% Within the Matlab editor, you can easily comment out code
% by highlighting it and hitting Ctrl-/ (or Command-/ on Mac).


% c. Built-in functions

% Matlab has a whole slew of built-in functions, and we've already
% used some of them. For example, rand() makes arrays of random
% numbers and dir() creates a structure based off of files in a 
% directory.
% It's pretty pointless to study a list of built-in functions -
% you'll pick them up as you go.

% I'm not going to say much more, except that if you are wondering
% whether Matlab has a built-in function for something, just
% google it. The documentation is extremely good. 

% d. Logical operators

% Logical operators allow us to make logical statements that evaluate
% to true or false. Think of them as claims.
1 == 1
% Here I'm claiming that 1 is equal to 1. This is true, so the whole
% statement evaluates to true.
% Note that, because we already use = to assign variables, we must use ==
% as the 'equals' operator here.
1 < 1
1 > 1
1 >= 1
1 <= 1 

% These are technically considered "relational operators", because we're 
% examining the relationship between two things, but they rely on a logical
% backbone. 
% Here are statements with 'real' logical operators:
1 & 1 % & : and
1 & 0
1 | 0 % | : or
1 | 1
xor(1,1)
xor(1,0)
% Remember that Matlab thinks about logical values (booleans) as the numbers 1 and 0.
% So the first statement here is a claim: true and true. This evaluates to true.
% Intuitively, this makes sense. If you know two things are true, you know they're both true.
% But if you only know that one of them is true (line 2), you don't know they're both true.
% You do know that at least one of them is true (line 3).
% And you also know that, if they're both true, at least one is true (line 4).
% What about the claim that *only one* of the two is true?
% This is the xor operator, which in Matlab is a function called xor().
% Line 5 claims that 1 or 1 is true, but both aren't. That's clearly false.
% Line 6 claims that either 1 or 0 is true, but both aren't. That's true. 
~(1&1)
~(1&0)
% We can flip any statement's truth value with the not operator, ~.

% All of these examples have been with numbers, but that's just scratching
% the surface. Some functions *also* make claims, and can thus evaluate to
% true or false. 
% For example:
ischar('a')
% evaluates to true. We can then put it in a logical statement:
ischar('a') & ischar('b')
% Both sides of the & evaluate to true (1), so the whole claim is true.
% And we can negate it with ~:
~ischar(1)
% ischar(1) was a false claim, so when we flip it, it's true.

% e. Flow

% OK, so at this point we can tell Matlab to do some things. Good.
% Clearly, if we want it to do more than one thing, we could just
% put all the commands we want into a .m script and run the script. 
% And sometimes this is all we need to do.

% But more often, we want to tell Matlab not only *what* to do,
% but *when* and *whether* to do it.
% This is control flow.

% Two visual metaphors underlie control flow: branching and looping.
% If you like visualizing, you can imagine a city map and a racetrack respectively.
% Branching -> think of intersections; you traverse different paths inside the city,
% turning down different streets depending on where you want to go.
% Looping -> think of laps; you run around a track, doing something every time.

% i. Branching

if 1==1
	disp('True')
else
	disp('False')
end
% Think of Matlab as a person reading through your list of instructions.
% When it gets to an 'if' statement, it'll pause and think about whether the
% statement is true or false.
% If it's true, Matlab does whatever you tell it to do in the 'if' block underneath.
% If it's false, Matlab sees if it's got any alternatives (the 'else' keyword).

% When Matlab hits the end statement, it knows it's done, and moves on. 
% Every 'if' needs a corresponding 'end'.

% The above example is kinda dumb because 1=1 is always true, so this code
% will never, ever display 'False'.

% A better example:
a=randn(1);
if a < 0.5
	disp('Too small')
else if a == 0.5
	disp('Just right')
else
	disp('Too large')
end
end
% a is a random number. There are three branches at this intersection: either a is exactly
% 0.5, it is larger, or it is smaller. We handle all three possibilities 
% with the help of 'else if'.

% Note that 'else if' demands its own 'end' too!

% When you have an especially large number of branches, you can use 'switch'.
% Run the following block of code all at once:
in_string = input('Type your favorite color: ','s');
switch in_string
case 'blue'
	disp('bleu')
case 'red'
	disp('rouge')
case 'green'
	disp('vert')
case 'yellow'
	disp('jaune')
case 'black'
	disp('noir')
otherwise
	disp('Unrecognized color!')
end
% Matlab will exhaustively check to see if what you entered
% matches any of the cases it knows about.
% If none match, then it'll do whatever's in the 'otherwise' block.


% ii. Looping

for i=1:10
	disp(num2str(i))
end
% This function will print out the numbers 1 through 10. 
% Again, think of Matlab reading down the list of instructions in order.
% When it begins, it sets i = 1, then goes down through the instructions.
% Then it comes back around to the top, sets i = 2, and goes through again.
% Since i is different every time, the statement in the loop's body - disp(num2str(i)) 
% - gives a different answer every time.
% It will only do this for values of i between 1 and 10 - 
% after 10, it'll stop looping and go on to whatever's next.

for i=1:10
	for j=1:10
		disp(num2str(i*j))
	end
end

% You can make *nested loops* too. These are the workhorses of many younglab scripts.
% Let's think: how many total loops is the code above making?

% The answer is 100. There are ten possible values for i, and ten for j. 
% On the first run through the outer loop, i = 1.
% Then, *still within that run*, we run through all ten values of j via the inner loop.
% So, we'll loop 10x on the outside, and for each one of those, loop 10x on the inside.

% Here's an example of a 3-level nested loop from a lab script I wrote.
% (Don't try to run it, you don't have the necessary variables.)

for sub=1:length(subjs) % for every subject
    for sessnum=1:4 % for every fMRI session
        matname=dir([subjs{sub} '.*f*.' num2str(sessnum) '.mat']); 
        % ^get the .mat file for that subject/session
        matname=matname.name;
        load(matname); % and load it into our workspace
        for cond=1:2 % then for every condition
            conditions.onsets{cond}{sub}{sessnum}=spm_inputs(cond).ons;
            conditions.durations{cond}{sub}{sessnum}=spm_inputs(cond).dur;
            % take that condition's info from the loaded .mat file
            % and use it to fill in a cell for that subject/session/condition
        end
    end
end

% There are also while loops, which I almost never use. 
i = 1;
while i <= 10
	disp(num2str(i))
% 	i = i + 1;
end
% Every time Matlab loops back to the 'while' statement, it checks to 
% make sure the statement still evaluates to true.
% Here, the statement will evaluate to false as soon as i = 11.
% Since we're adding 1 to i on every run through the loop,
% this means the loop will execute 10 times and then stop.

% What if we just want the loop to stop?
% We can break out of the loop:
for i=1:10
	if i == 7
		break
	else
		disp(num2str(i))
	end
end
disp('end loop')
% As soon as i = 7, Matlab will hit the 'if' statement, break out of the loop,
% and move on as if the loop no longer exists.
% Break will only take you out of the loop in which it appears. So, you could
% break out of an inner loop, but that won't stop the outer loop.

% You can also skip over parts of a loop using 'continue'.
for i=1:10
	if i == 7
		continue
	end
	disp(num2str(i))
end
disp('end loop')
% Continue tells Matlab, "I'm done with this particular run through the loop, so 
% go on to the next one."
% This loop will never display the number 7, because when i = 7, we immediately
% skip to the next run (i = 8), before we even hit the disp() call.

% 2. FUNCTIONS

% a. The anatomy of a function

% Matlab will not allow you to define functions within the terminal.
% So, copy and paste the below definition into your editor window and 
% save it as thisFunction.m in order to use it.

function [output_1, output_2] = thisFunction(parameter_1,parameter_2) % definition
	% body
	output_1 = num2str(parameter_1);
	output_2 = num2str(parameter_2);
end % end statement

% function: keyword that indicates you're defining a function here.

% []: contain variables to name what the function is putting out.
% output_1, output_2: your output variables.
% These variables must appear somewhere inside the body of your function 
% (everything between your function definition at top and the end
% statement at the bottom).

% thisFunction: the name by which your function will be known.
% If a .m file contains a function only, its name should match
% the function name (so, this should be saved as thisFunction.m).

% (): contain your parameters.
% parameter_1, parameter_2: variables naming what you're putting into the function.
% A key thing to remember is that the exact names you put in DON'T have to appear anywhere
% but your function definition. We can give the function anything as parameters when
% we call it - they'll get renamed by the function so it can use them.
% For example:
one=1; two=2;
thisFunction(one,two)
% works, even though we never type 'parameter_1' and 'parameter_2'.
% Because we gave our variables one and two to the function in a certain order,
% it knows how to rename them and process them internally.

% end: marks the end of the function definition.
% Everything between the definition line of the function and the 'end' is what
% the function will do when it's called - the body of the function. 

% b. Function workspaces

% This page: 
% http://www.mathworks.com/help/matlab/matlab_prog/base-and-function-workspaces.html
% reminds you that functions make their own workspaces.
% So, let's say I have a function:
function thisFunction(number)
	disp(num2str(multiplier*number))
end
% and a variable in my Matlab workspace:
multiplier = 10;
% It seems like thisFunction would be able to use multiplier,
% since the word multiplier appears inside the function.
% But actually, multiplier only exists outside, in the base Matlab workspace.
% thisFunction only knows about things inside its own workspace - in this
% case, it only knows the value of number.

% You get around this by 1. defining things inside the function and
% 2. passing whatever you need to your function as a parameter.
% In this example, that would be respectively:
function thisFunction(number)
	multiplier=10;
	disp(num2str(multiplier*number))
end
% and
function thisFunction(number,multiplier)
	disp(num2str(multiplier*number))
end

% You can also define functions inside functions (nesting). A nested function
% has access to everything within the function that contains it.

function thisFunction(number)
	multiplier=make_multiplier();
	disp(num2str(multiplier*number))

	function [OUTPUT] = make_multiplier()
		OUTPUT = randi; 
	end
end

% 3. DEBUGGING

% a. The stack trace

% If you mess something up in Matlab, you can get a 'stack trace'
% of errors. This occurs when you've called multiple functions.
% For example, if there's a mistake on line 15 of function B,
% and function A calls B at line 30, you'll get a stack trace
% showing both an error in B (line 15) and an error in A (line 30).
% Like an awesome super-sleuth, you can step through the stack trace
% to figure out where you need to change your code.

% b. Some common errors

% Index exceeds matrix dimensions
A=zeros(3,5); A(4,1)
% (A has no fourth row)

% Unexpected Matlab operator
A(:)
A(::)
% (Can't use two colons in a row)

% The expression to the left of the equals sign is not a valid target for an assignment
if length(A) = 5
	disp('Yay!')
end
% (Here, we should have used == instead)

% Possibly unbalanced (, {, or [
cd(fullfile('Users','wass','Documents')
% (We're missing a final parenthesis)

% Expression or statement is incomplete/incorrect
% Try this:
B = 10+3+...
+9;
% Then this:
B = B+
8;
% (Need to use ... to indicate our statement continues on the next line)

% Undefined command/function
f = thisfunctiondoesnotexist(A);

% Not enough input arguments/too many output arguments
A=randn(5,1);B=randn(5,1);
C=corrcoef(A,B)
C=corrcoef(A)
C=corrcoef()
help corrcoef
% (corrcoef needs at least one argument, as the documentation shows)

% c. Dealing with bugs

% Some tips:
% - Use the stack trace if it's there!
% - Put print statements in your code to figure out
% how far it's getting before it errors out
% - If it's something especially complicated, put in
% save statements at various points in your code,
% then use them as snapshots to see what your variables
% looked like at each timepoint
% - Try the dumbest fix first (aka the "unplug it"
% method of tech support)
% - Take 'try' statements out of your code. They're
% recommended by coders because they can ensure that your
% code runs no matter what, but for our purposes,
% we often *want* the script to error out if something is bad, 
% and we *want* it to give us the most informative
% stack trace possible.
% - Make your code verbose to start out with. Have it 
% print out what it's doing as it's doing it.

% d. Debug mode

% Debug mode allows you to pause function execution and examine the
% variables in your workspace.
% This is useful because otherwise, any variables named and manipulated
% inside your function won't appear in your base workspace. So, for example,
% if some variable within your function is taking on the wrong value and
% causing an error, you won't be able to see it, unless you exit to debug mode.

function thisFunction(number,multiplier)
	% Lots of stuff might be here...
	extra=1;
	multiplier=multiplier+extra;
	% and some more stuff here...
	disp(num2str(multiplier*number))
end

% Let's say that at some point inside our function thisFunction,
% we accidentally left in a line that increases multiplier by 1.
% So our displayed output is higher than we expect, by (number).
% To figure out why this is, I'll put in a keyboard statement
% right before the disp() call, and run the function again:

function thisFunction(number,multiplier)
	% Lots of stuff might be here...
	extra=1;
	multiplier=multiplier+extra;
	% and some more stuff here...
	keyboard
	disp(num2str(multiplier*number))
end

thisFunction(5,10)

% Your program should now be paused, and you should see an extra variable
% in your workspace: extra. 
% You should also be able to see that multiplier = 11 - which gives you
% a clue that something happened to multiplier inside the body of your function
% to make it larger than you expected it to be.
% To resume running the function, type:
dbcont

% Now call thisFunction again:
thisFunction(4,5)
% and instead of dbcont, type:
dbquit
% This ends the execution of your function.
% So if you've looked at your code, and realized something is wrong,
% you can make the function stop so you can take some time to fix it.

% You can also display variables, or change variables manually, while you are
% in debug mode.
% First run this:
thisFunction(3,7)
% Then this:
extra
multiplier=7;
% Then this:
dbcont
% Here, I look at the value of extra, then change multiplier back to its original
% value of 7, then keep running the function.
% This time, it should display the output I want (21).








