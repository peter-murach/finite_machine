# encoding: utf-8

module FiniteMachine
  # A class responsible for defining event methods on state machine
  #
  # Used to add event definitions from {TransitionBuilder} to
  # the {StateMachine} to obtain convenience helpers.
  #
  # @api private
  class EventDefinition
    include Threadable
    include Safety

    # The current state machine
    attr_threadsafe :machine

    # Initialize an EventBuilder
    #
    # @param [FiniteMachine::StateMachine] machine
    #
    # @api private
    def initialize(machine)
      @machine = machine
    end

    # Define transition event names as state machine events
    #
    # @param [Transition] transition
    #   the transition for which event definition is created
    #
    # @return [Transition]
    #
    # @api private
    def apply(event_name)
      detect_event_conflict!(event_name)
      define_event_transition(event_name)
      define_event_bang(event_name)
    end

    private

    # Define transition event
    #
    # @param [Symbol] name
    #   the event name
    #
    # @param [FiniteMachine::Transition] transition
    #   the transition this event is associated with
    #
    # @return [nil]
    #
    # @api private
    def define_event_transition(event_name)
      context = self
      machine.send(:define_singleton_method, event_name) do |*data|
        event_transition = machine.events_chain.next_transition(event_name)
        context.send(:run_transition, event_transition, *data)
      end
    end

    # @api private
    def run_transition(event_transition, *data)
      sync_exclusive do
        if !event_transition.cancelled? && event_transition.silent?
          machine.send(:transition!, event_transition, *data)
        else
          machine.send(:transition, event_transition, *data)
        end
      end
    end

    # Define event that skips validations
    #
    # @param [Symbol] name
    #   the event name
    #
    # @return [nil]
    #
    # @api private
    def define_event_bang(name)
      machine.send(:define_singleton_method, "#{name}!") do
        transitions   = machine.transitions[name]
        machine.state = transitions.values[0]
      end
    end
  end # EventBuilder
end # FiniteMachine