addpath('/home/younglw/scripts');

for subject_number=[3:47]
	try
		janky_contrast(subject_number);
	catch
		disp(['Could not make contrast for subject number ' sprintf('%02d',subject_number)])
		continue
	end
end