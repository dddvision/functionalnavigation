classdef DataContainerTest < handle
  
  methods (Access=public)
    function this=DataContainerTest(name,initialTime)
      fprintf('\n\n*** DataContainerTest ***');
            
      fprintf('\n\ntom.DataContainer.description =');
      text=tom.DataContainer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\ntom.DataContainer.create =');
      dataContainer=tom.DataContainer.create(name,initialTime);
      assert(isa(dataContainer,'tom.DataContainer'));
      fprintf(' ok');
    end
  end
  
end
