use Test2::Bundle::Extended -target => 'Scientist';

=for ruby

describe Scientist::Result do
  before do
    @experiment = Scientist::Experiment.new "experiment"
  end

=cut

subtest describe_scientist_result => sub {

=for ruby

  it "is immutable" do
    control = Scientist::Observation.new("control", @experiment)
    candidate = Scientist::Observation.new("candidate", @experiment)

    result = Scientist::Result.new @experiment, [control, candidate], control
    assert result.frozen?
  end

=cut

    subtest "is immutable" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "evaluates its observations" do
    a = Scientist::Observation.new("a", @experiment) { 1 }
    b = Scientist::Observation.new("b", @experiment) { 1 }

    assert a.equivalent_to?(b)

    result = Scientist::Result.new @experiment, [a, b], a
    assert result.matched?


    refute result.mismatched?
    assert_equal [], result.mismatched

    x = Scientist::Observation.new("x", @experiment) { 1 }
    y = Scientist::Observation.new("y", @experiment) { 2 }
    z = Scientist::Observation.new("z", @experiment) { 3 }

    result = Scientist::Result.new @experiment, [x, y, z], x
    refute result.matched?
    assert result.mismatched?
    assert_equal [y, z], result.mismatched
  end

=cut

    subtest "evaluates its observations" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "has no mismatches if there is only a control observation" do
    a = Scientist::Observation.new("a", @experiment) { 1 }
    result = Scientist::Result.new @experiment, [a], a
    assert result.matched?
  end

=cut

    subtest "has no mismatches if there is only a control observation" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "evaluates observations using the experiment's compare block" do
    a = Scientist::Observation.new("a", @experiment) { "1" }
    b = Scientist::Observation.new("b", @experiment) { 1 }

    @experiment.compare { |x, y| x == y.to_s }

    result = Scientist::Result.new @experiment, [a, b], a

    assert result.matched?, result.mismatched
  end

=cut

    subtest "evaluates observations using the experiment's compare block" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "does not ignore any mismatches when nothing's ignored" do
    x = Scientist::Observation.new("x", @experiment) { 1 }
    y = Scientist::Observation.new("y", @experiment) { 2 }

    result = Scientist::Result.new @experiment, [x, y], x

    assert result.mismatched?
    refute result.ignored?
  end

=cut

    subtest "does not ignore any mismatches when nothing's ignored" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "uses the experiment's ignore block to ignore mismatched observations" do
    x = Scientist::Observation.new("x", @experiment) { 1 }
    y = Scientist::Observation.new("y", @experiment) { 2 }
    called = false
    @experiment.ignore { called = true }

    result = Scientist::Result.new @experiment, [x, y], x

    refute result.mismatched?
    refute result.matched?
    assert result.ignored?
    assert_equal [], result.mismatched
    assert_equal [y], result.ignored
    assert called
  end

=cut

    subtest "uses the experiment's ignore block to ignore mismatched observations" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=cut

  it "partitions observations into mismatched and ignored when applicable" do
    x = Scientist::Observation.new("x", @experiment) { :x }
    y = Scientist::Observation.new("y", @experiment) { :y }
    z = Scientist::Observation.new("z", @experiment) { :z }

    @experiment.ignore { |control, candidate| candidate == :y }

    result = Scientist::Result.new @experiment, [x, y, z], x

    assert result.mismatched?
    assert result.ignored?
    assert_equal [y], result.ignored
    assert_equal [z], result.mismatched
  end

=cut

    subtest "partitions observations into mismatched and ignored when applicable" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "knows the experiment's name" do
    a = Scientist::Observation.new("a", @experiment) { 1 }
    b = Scientist::Observation.new("b", @experiment) { 1 }
    result = Scientist::Result.new @experiment, [a, b], a

    assert_equal @experiment.name, result.experiment_name
  end

=cut

    subtest "knows the experiment's name" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "has the context from an experiment" do
    @experiment.context :foo => :bar
    a = Scientist::Observation.new("a", @experiment) { 1 }
    b = Scientist::Observation.new("b", @experiment) { 1 }
    result = Scientist::Result.new @experiment, [a, b], a

    assert_equal({:foo => :bar}, result.context)
  end
end

=cut

    subtest "has the context from an experiment" => sub {
        todo scientist_observation_unimplemented => sub {
            fail;
        };
        todo scientist_result_unimplemented => sub {
            fail;
        };
   };

}; # end describe_scientist_result

done_testing;