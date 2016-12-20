How do I:

1. Specify which processing steps I want to run?

   In your parameters file (*_params_*.json), look for the key "node_flags".
   Here, you'll see a dictionary with the names of nodes as keys, and either 0 or 1 as values.
   To include a node, set its value here to 1.
   To exclude a node, set its value here to 0.
   
2. Specify which software I want to use for my whole pipeline?

   In your parameters file (*_params_*.json), look for the key "global_software_specs".
   Set "use_global_specs" here to 1, and then specify the name of your software in "software".
   Available names include: "spm","afni","fsl".

3. Mix different software packages in my pipeline?

   First, set "global_software_specs" -> "use_global_specs" to 0 in your parameters file.
   Next, for each node you want to include, you'll have to set its associated "local_software_spec" value.
   Go to "params", and find the name of your node, then set "local_software_spec" to whatever software you are using for that node.
   Available names include: "spm","afni","fsl".
   You must do this for EVERY node you plan to include in your workflow.
	
4. Specify my experimental info?

 In the parameters file, you'll find this information under "directories" and "experiment_details".
 If it's your first time filling in this information, use configure_nipype_params.py to set up your experiment.
 This program will interactively prompt you to enter information about your experiment, including your study name, workflow name, subject tag, subject numbers, and task names.
 It will then automatically fill in the other information you need, such as onsets and durations, from your behavioral .mat files.
 After running this program, the information will be saved in your own parameters file, and you'll be able to manually edit it (e.g., to enter missing values).

5. Connect nodes together into a workflow?

 yl_nipype_MASTER.py will automatically connect your nodes unless you tell it not to.
 By default, it will connect the nodes in the order in which they appear under "node_flags" in your parameters file.
 Thus, if I have "dicom", "realign", and "reslice" set to 1, yl_nipype_MASTER will join those three nodes in that order.
 (It will NOT include the "slicetime" node, since I didn't set it to 1, even though it appears directly after "dicom".)

6. Custom-specify which files I want a node to take as input?

 Sometimes, you may NOT want a node to take its inputs from a preceding node. 
 For example, let's say I have already done preprocessing in a previous workflow, but now I want to do modeling in a new one.
 The first node of my new workflow will run my model specification, but since it has no previous node to connect with,
 I can't simply rely on yl_nipype_MASTER.py to automatically specify the appropriate input files.
 In your parameters file, find the name of the node you are working on under "params", and set "infile_dir" to the full path to the directory in which your input files live. In my example, I'll say that this is '/home/younglw/lab/myStudy/preproc_wf/normalize'.
 Then, set "specify_inputs" to 1. 
 This tells yl_nipype_MASTER not to use a previous node's outputs for this node's inputs, but instead to look in "infile_dir" for the input files.
 You can see the specific type of files it grabs from "infile_dir" under the configure_node() function definition for that node.
 In this example, "specify_design" grabs '.nii' files by default, and so any .nii files in my normalize subdirectory above will be grabbed.

7. Change the value of a processing parameter for a given node?

 All the processing parameters for a given node are in your parameters file, under "params" and the name of that node.
 yl_nipype_params_MASTER.json contains the default processing parameters. 
 When you edit your own params file, you can overwrite these parameters.
 Please DO NOT edit yl_nipype_params_MASTER.json directly! Always work on your own copy of the parameters file.

8. Add a processing parameter that isn't in the default params template?

 In your own parameters file, under "params", find the name of the given node and add a key/value pair.
 You MUST prepend the key with "custom_" to let yl_nipype_MASTER know that it needs to find and include this new parameter. 
	
9. Change which software function a given node uses?

 The mapping between node names and software functions is defined in your *_software_dict_*.json file.
 Please DO NOT edit yl_nipype_software_dict_MASTER.json directly! Always work on your own copy of the software dict file.
	
10. Change which inputs/outputs are joined across two nodes?

 This is defined in your *_software_dict_*.json file.
 Please DO NOT edit yl_nipype_software_dict_MASTER.json directly! Always work on your own copy of the software dict file.
 Within this file, you can see that every node has keys called "inp" and "output".
 These tell yl_nipype_MASTER which input and output variables to join when connecting two nodes.
 For example, the default output of "estimate" is a list of length 3, comprising the beta images, SPM.mat, and residual image files.
 The default input of "contrast" is also a list of length 3.
 This means that in a workflow, yl_nipype_MASTER can join these nodes, sending the outputs of "estimate" to the inputs of "contrast".
 However, let's say that after "estimate", I wanted to run a one-sample T-test on the beta images instead.
 I could set the "output" value for "estimate" to specify only the beta images.
 Thus, yl_nipype_MASTER will be able to join the "estimate" and "onesample_T" nodes inside a workflow, passing the output of "estimate" (the beta images) into the input of "onesample_T" (the "in_files", or input files).
 Please consult the nipype documentation to see the names of input and output files - nipype automatically names the inputs/outputs and therefore you must use these names. For example, I cannot call my "estimate" output "beta_volumes" instead of "beta_images".

11. Iterate over multiple values of a parameter for a given node?

12. Use my own functions, or functions from a third-party package?
	
x. Change yl_nipype_MASTER.py?

 First, make sure that there's absolutely no way you can do what you want by modifying the parameters or software dict files.
 If you are convinced you must edit the script, make sure you are editing your OWN COPY, that you have renamed.
 I recommend consulting the flow diagram of yl_nipype_MASTER to figure out what each chunk of the code is doing before you start editing.
 After that, you are on your own - happy coding!
