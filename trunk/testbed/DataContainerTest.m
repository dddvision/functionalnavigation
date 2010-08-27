classdef DataContainerTest < handle
  
  methods (Access=public)
    function this=DataContainerTest(name)
      fprintf('\n\nDataContainer.description =');
      text=DataContainer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\nDataContainer.factory =');
      dataContainer=DataContainer.factory(name);
      assert(isa(dataContainer,'DataContainer'));
      fprintf(' ok');
    end
  end
  
end
