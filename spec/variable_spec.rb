require 'spec_helper'

describe "Variable" do
  let(:graph) { Tensorflow::Graph.new }

  it "sets the variable name when it is specified" do
    no_name1 = graph.variable([1, 2, 3],  name: "testing_names")
    expect(no_name1.ref.name).to eq("testing_names")
  end

  it "sets a default name if none is specified" do
    no_name = graph.variable([1, 2, 3])
    expect(no_name.ref.name).to eq("Variable_0")
  end

  it "increments the default variable name for each unnamed variable" do
    no_name1 = graph.variable([1, 2, 3])
    no_name2 = graph.variable([4, 5, 6])
    expect(no_name1.ref.name).to eq("Variable_0")
    expect(no_name2.ref.name).to eq("Variable_1")
  end

  it "increments variable and constant names separately" do
    variable0 = graph.variable([0])
    constant0 = graph.constant([0])
    variable1 = graph.variable([1])
    expect(variable0.ref.name).to eq("Variable_0")
    expect(constant0.definition.name).to eq("Constant_0")
    expect(variable1.ref.name).to eq("Variable_1")
  end

  it "subtracts tensors across multiple sessions" do
    input1 = graph.variable([343,32], dtype: :int32, name: "input1")
    input2 = graph.constant([33,42], dtype: :int32, name: "input2")
    add = graph.define_op("Sub",'add_tensors', [input1, input2],"",nil)
    graph.define_op("Assign",'assign_inp1', [input1, add],"",nil)
    graph.intialize_variables
    session = Tensorflow::Session.new
    graph.graph_def_raw = graph.graph_def.serialize_to_string
    session.intialize_variables_and_extend_graph(graph)
    result = session.run(nil, ["input1"], ["assign_inp1"])
    result = session.run(nil, ["input1"], ["assign_inp1"])
    result = session.run(nil, ["input1"], ["assign_inp1"])
    expect(result[0]).to match_array([244, -94])
  end
end
