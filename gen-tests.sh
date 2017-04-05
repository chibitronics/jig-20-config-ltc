#!/bin/sh

testify() {
	local testfile="$1"
	local id=$(echo ${testfile} | cut -d'.' -f1)
	local varname=$(echo ${id} | tr '-' '_')
	local requires=""
	for dep in $(grep Requires= ${testfile} | cut -d= -f2 | tr ',' ' ')
	do
#		echo "Requirement for ${id}: ${dep}"
		if [ -z "${requires}" ]
		then
			requires="vec![\"${dep}\".to_string()"
		else
			requires="${requires}, \"${dep}\".to_string()"
		fi
	done
	if [ -z "${requires}" ]
	then
		requires="vec!["
	fi
	requires="${requires}]"

	local suggests=""
	for dep in $(grep Suggests= ${testfile} | cut -d= -f2 | tr ',' ' ')
	do
#		echo "Suggestion for ${id}: ${dep}"
		if [ -z ${suggests} ]
		then
			suggests="vec![\"${dep}\".to_string()"
		else
			suggests="${suggests}, \"${dep}\".to_string()"
		fi
	done
	if [ -z "${suggests}" ]
	then
		suggests="vec!["
	fi
	suggests="${suggests}]"

	local provides=""
	for dep in $(grep Provides= ${testfile} | cut -d= -f2 | tr ',' ' ')
	do
#		echo "Provides for ${id}: ${dep}"
		if [ -z ${provides} ]
		then
			provides="vec![\"${dep}\".to_string()"
		else
			provides="${provides}, \"${dep}\".to_string()"
		fi
	done
	if [ -z "${provides}" ]
	then
		provides="vec!["
	fi
	provides="${provides}]"

	echo "let ${varname} = SimpleDep::new(\"${id}\", ${requires}, ${suggests}, ${provides});"
	echo "depgraph.add_dependency(&${varname});"
}

for testfile in $(ls -1 *.test)
do
	testify "${testfile}"
done
