classdef DataContainerTest < handle
  
  methods (Access=public)
    function this=DataContainerTest(name)
      fprintf('\n\ntom.DataContainer.description =');
      text=tom.DataContainer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\ntom.DataContainer.factory =');
      dataContainer=tom.DataContainer.factory(name);
      assert(isa(dataContainer,'tom.DataContainer'));
      fprintf(' ok');
    end
  end
  
end
