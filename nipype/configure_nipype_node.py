import json, argparse

def configure_nipype_node(paramfile):
	'''open param file & specify parameters/node_flag for a given node'''

	def input_process(old_value,new_value):
		if not isinstance(old_value,list):
			return eval(type(old_value).__name__+'(new_value)')
		else:
			if len(old_value):
				new_value=[input_process(old_value[0],x) for x in new_value.split(' ')]
			else:
				new_type=input("Enter desired type for list items (str/int/float/bool): ")
				new_value=[eval(new_type+'(x)') for x in new_value.split(' ')]
			return new_value
			

	def loop_node_params(node_name):
		'''loop through node parameters and specify their value'''
		print("To preserve a parameter value, hit Enter without typing anything.")
		print("To enter a list of items, separate entries with spaces.")
		for k in params["params"][node_name].keys():
			print("Current value of "+k+" : ")
			print(params["params"][node_name][k])
			new_value = input("Enter value for "+k+": ")
			if new_value:
				params["params"][node_name][k]=input_process(params["params"][node_name][k],new_value)

	def turn_on_node(node_name):
		'''set node_flag to 1 to include this processing step'''
		turn_on = input("Turn on this node? (y/n) ")
		if turn_on == 'y':
			params["node_flags"][node_name]=1
		else: 
			params["node_flags"][node_name]=0

	print("Editing your parameter file "+args.parameter_file)
	with open(args.parameter_file+'.json','r') as jsonfile:
		params=json.load(jsonfile)
	print("***Instructions:***\nType the name of the node you would like to edit.")
	print("Available nodes: ")
	print([k for k in params["node_flags"].keys()])
	print("To end this program, hit Enter instead of typing a node name.")
	node_name = input("Enter name of node to edit: ")
	while len(node_name):
		loop_node_params(node_name)
		turn_on_node(node_name)
		node_name = input("Enter name of node to edit: ")
	print("Saving your parameter file.")
	with open(args.parameter_file+'.json','w') as jsonfile:
		json.dump(params,jsonfile)

parser = argparse.ArgumentParser()
parser.add_argument("parameter_file",help="The full path to your parameter file, minus the .json extension")
args = parser.parse_args()
configure_nipype_node(args)
