import sys
import java.io.FileReader as FileReader
import java.lang.StringBuffer as StringBuffer
import java.lang.Boolean as Boolean

import weka.core.Instances as Instances
import weka.classifiers.trees.J48 as J48
import weka.classifiers.Evaluation as Evaluation
import weka.core.Range as Range
import weka.classifiers.functions.MultilayerPerceptron as MultilayerPerceptron
import weka.core.SerializationHelper as SerializationHelper

# check commandline parameters
if (not (len(sys.argv) == 3)):
    print "Usage: UsingJ48Ext.py <ARFF-file>"
    sys.exit()

file = FileReader(sys.argv[1])
file2 = FileReader(sys.argv[2])
data = Instances(file)
test = Instances(file2)
data.setClassIndex(data.numAttributes() - 1)
test.setClassIndex(test.numAttributes() - 1)
evaluation = Evaluation(data)
buffer = StringBuffer()
attRange = Range()  # no additional attributes output
outputDistribution = Boolean(False)  # we don't want distribution
nn = MultilayerPerceptron()
nn.buildClassifier(data)  # only a trained classifier can be evaluated

#print evaluation.evaluateModel(nn, ['-t', sys.argv[1], '-T', sys.argv[2]])#;, [buffer, attRange, outputDistribution])
res = evaluation.evaluateModel(nn, test, [buffer, attRange, outputDistribution])
f = open('predictions/' + data.relationName(), 'w')
for d in res:
	f.write(str(d) + '\n');
f.close()	

SerializationHelper.write("models/" + data.relationName() + ".model", nn)

# print out the built model
#print "--> Generated model:\n"
#print nn

#print "--> Evaluation:\n"
#print evaluation.toSummaryString()

#print "--> Predictions:\n"
#print buffer
