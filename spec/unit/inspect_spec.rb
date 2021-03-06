# frozen_string_literal

RSpec.describe FiniteMachine, "#inspect" do
  it "print useful information about state machine" do
    fsm = FiniteMachine.new do
      initial :green

      event :slow,  :green  => :yellow
      event :stop,  :yellow => :red
    end
    inspected = fsm.inspect
    expect(inspected).to match(/^<#FiniteMachine::StateMachine:0x#{fsm.object_id.to_s(16)} @current=:green @states=\[.*\] @events=\[.*\] @transitions=\[.*\]>$/)

    event_names = eval inspected[/events=\[(.*?)\]/]
    states = eval inspected[/states=\[(.*?)\]/]
    transitions = eval inspected[/transitions=\[(.*?)\]/]

    expect(event_names).to match_array([:init, :slow, :stop])
    expect(states).to match_array([:none, :green, :yellow, :red])
    expect(transitions).to match_array([{:none => :green}, {:green => :yellow}, {:yellow => :red}])
  end
end
