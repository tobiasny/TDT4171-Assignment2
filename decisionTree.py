from math import log
import random
import copy

def ExtractDataFromFile(filename):
	data = []
	file = open(filename, 'r')
	for line in file.readlines():
		data.append(line.rstrip("\n").split("\t"))
	return data

def PluralityValue(data):
	p, n = 0, 0
	for row in data:
		if row[-1] == '2':
			p += 1
		else:
			n += 1
	if p > n:
		return 2
	elif n > p:
		return 1
	else:
		return random.randint(1,2)

def AllSameClassification(data):
	count = 0
	for row in data:
		if row[-1] == '1':
			count += 1
	if count == 0 or count == len(data):
		return True
	else:
		return False

def B(q):
    if q==0:
    	return -(1-q)*log((1-q),2)
    elif q==1:
    	return -(q*log(q,2))
    else:
        return -(q*log(q,2) + (1-q)*log(1-q,2))

def Importance(data,attributes):
	entropy = [0 for x in range(8)]
	for a in attributes:
		count = 0
		for row in data:
			if row[a] == data[0][a]:
				count += 1
		entropy[a] = B(count/len(data))

	minimum = 1.1
	a = None
	for i in range(len(attributes)):
		if entropy[i] < minimum:
			minimum = entropy[i]
			a = attributes[i]
	return a

class Tree():
	def __init__(self,val):
		self.val = val
		self.children = {}

	def printTree(self):
		if len(self.children) == 0:
			return "[" + str(self.val) + "]"
		else:
			temp = "[" + str(self.val) + " "

		for key,_ in self.children.items(): 
			temp += self.children[key].printTree()

		return temp + "]\n"

def DecisionTreeLearning(data,attributes,parentData,randomizedImportance=False):
	if not data:
		return Tree(PluralityValue(parentData))
	elif AllSameClassification(data):
		return Tree(data[0][-1])
	elif not attributes:
		return Tree(PluralityValue(data))
	else:
		if randomizedImportance:
			A = attributes[random.randint(0,len(attributes)-1)]
		else:
			A = Importance(data,attributes)
		tree = Tree(A)
		attributes.remove(A)

		for x in range(1,3):
			newData = []
			for example in data:
				if int(example[A]) == x:
					newData.append(example)
			subtree = DecisionTreeLearning(newData,list(attributes),data,randomizedImportance)
			tree.children[x] = subtree
	return tree

def Classification(root, row):
	current = root
	while current.children:
		current = current.children[int(row[current.val])]
	return current.val


def Test(data,tree):
	hits = 0
	for row in data:
		if row[-1] == Classification(tree,row):
			hits += 1
	print("Hits: ", hits, " out of set size: ",len(data))


def main():
	trainingData = ExtractDataFromFile('training.txt')
	testData = ExtractDataFromFile('test.txt')
	attributes = [x for x in range(0, len(trainingData[0])-1)]

	print("Importance: ")
	tree = DecisionTreeLearning(trainingData,attributes,[])
	Test(testData,tree)
	print(tree.printTree())
	print("Randomized Importance: ")
	tree = DecisionTreeLearning(trainingData,attributes,[],True)
	Test(testData,tree)
	print(tree.printTree())

main()
