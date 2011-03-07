
import Trajectory

from abc import abstractmethod, ABCMeta

class DynamicModel(Trajectory.Trajectory):

    staticDescriptionList = {}
    
    @staticmethod
    def pDescriptionList():
        return DynamicModel.staticDescriptionList

    staticFactoryList = {}

    @staticmethod
    def pFactoryList():
        return DynamicModel.staticFactoryList

    def __init__(self, initialTime, uri):
        pass

    @staticmethod
    def connect(name, cD, cF):
        DynamicModel.pDescriptionList()[name] = cD
        DynamicModel.pFactoryList()[name] = cF

    @staticmethod
    def isConnected(name):
        return DynamicModel.pFactoryList().has_key(name)
    
    @staticmethod
    def description(name):
        return DynamicModel.pDescriptionList().get(name)

    @staticmethod
    def create(name, initialTime, uri):
        if DynamicModel.isConnected(name):
            return DynamicModel.pFactoryList().get(name)(initialTime, uri)
        else:
            raise ValueError('DynamicModel is not connected to the requested component')

    @staticmethod
    def initialize(name):
        pass

    @abstractmethod
    def numInitial(self):
        pass

    @abstractmethod
    def numExtension(self):
        pass

    @abstractmethod
    def numBlocks(self):
        pass

    @abstractmethod
    def getInitial(self, parameterIndex):
        pass

    @abstractmethod
    def getExtension(self, blockIndex, parameterIndex):
        pass

    @abstractmethod
    def setInitial(self, parameterIndex, value):
        pass

    @abstractmethod
    def setExtension(self, blockIndex, parameterIndex, value):
        pass

    @abstractmethod
    def computeInitialCost(self):
        pass

    @abstractmethod
    def computeExtensionCost(self, blockIndex):
        pass

    @abstractmethod
    def extend(self):
        pass

    @abstractmethod
    def copy(self):
        pass

