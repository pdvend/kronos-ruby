# frozen_string_literal: true

RSpec.describe Kronos do
  describe '.config' do
    subject { described_class.config(&block) }
    let(:block) { ->(*) {} }

    it { expect { subject }.to_not raise_error }
    it { expect { |b| described_class.config(&b) }.to yield_with_args(Kronos::ConfigAgent) }
  end

  describe '.tasks' do
    subject { described_class.tasks }

    it { is_expected.to be_a(Array) }

    context 'when there are tasks registered' do
      before do
        described_class.clear_tasks
        described_class.config { |agent| agent.register(:say_hello, 'monday') { puts 'Hello' } }
      end

      it { is_expected.to_not be_empty }
      it { expect(subject.length).to be(1) }
      it { is_expected.to all be_a(Kronos::Task) }
    end
  end

  describe '.clear_tasks' do
    subject { described_class.clear_tasks }

    it { is_expected.to be_nil }

    context 'when there are not tasks registered' do
      it { expect { subject }.to_not(change { Kronos.tasks.length }) }
    end

    context 'when there are tasks registered' do
      before do
        described_class.config { |agent| agent.register(:say_hello, 'monday') { puts 'Hello' } }
      end

      it { expect { subject }.to change { Kronos.tasks.length }.from(1).to(0) }
    end
  end
end
