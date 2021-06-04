# Copyright 2011 Scientific Systems Company Inc., New BSD License

import Measure, Trajectory, DynamicModel

from abc import abstractmethod, ABCMeta

class Optimizer(object):

    staticDescriptionList = {}
    
    @staticmethod
    def pDescriptionList():
        return Optimizer.staticDescriptionList

    staticFactoryList = {}

    @staticmethod
    def pFactoryList():
        return Optimizer.staticFactoryList

    def __init__(self):
        pass

    @staticmethod
    def connect(name, cD, cF):
        Optimizer.pDescriptionList()[name] = cD
        Optimizer.pFactoryList()[name] = cF

    @staticmethod
    def isConnected(name):
        return Optimizer.pFactoryList().has_key(name)
    
    @staticmethod
    def description(name):
        return Optimizer.pDescriptionList().get(name)

    @staticmethod
    def create(name, initialTime, uri):
        if Optimizer.isConnected(name):
            return Optimizer.pFactoryList().get(name)()
        else:
            raise ValueError('Optimizer is not connected to the requested component')

    @staticmethod
    def initialize(name):
        pass

    @abstractmethod
    def numInitialConditions(self):
        pass

    @abstractmethod
    def defineProblem(self, dynamicModel, measure, randomize):
        pass

    @abstractmethod
    def refreshProblem(self):
        pass

    @abstractmethod
    def numSolutions(self):
        pass

    @abstractmethod
    def getSolution(self, k):
        pass

    @abstractmethod
    def getCost(self, k):
        pass

    @abstractmethod
    def step(self):
        pass

