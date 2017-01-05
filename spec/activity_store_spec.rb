require "array"
require "activity_store"
require "activity"
require "activity_data"
require "course"
require "pg"
require "postgres_parser"
require "pry"
require "rb-readline"

RSpec.describe ActivityStore do
  let(:day) { 60 * 60 * 24 }

  let(:test_database_name) { 'peak-hills-test' }
  subject(:activity_store) { ActivityStore.new(test_database_name) }
  let(:connection) { PG.connect(dbname: test_database_name) }

  before do
    connection.exec("DELETE FROM activities_hills")
    connection.exec("DELETE FROM activities")
  end

  describe 'pushing and getting all activitities' do
    context 'with new activity data' do
      let(:new_activity_data) {
        ActivityData.new(
          1,
          "A walk up t' hill",
          Time.now,
          [[1.1234,1.1234], [1.434,2.434]]
        )
      }

      before do
        activity_store.push(new_activity_data)
        @results = activity_store.get_all
      end

      it 'inserts a row in the database' do
        expect(@results.count).to be 1
      end

      it 'writes the id as expected' do
        expect(@results.first.id).to eq(new_activity_data.id)
      end

      it 'writes the name as expected' do
        expect(@results.first.name).to eq(new_activity_data.name)
      end

      it 'writes the started at date as expected' do
        expect(@results.first.started_at).to eq(
          new_activity_data.started_at.strftime('%Y-%m-%d %H:%M:%S')
        )
      end

      it 'writes the course data as expected' do
        expect(@results.first.course.geo_points).to eq(
          Course.new(new_activity_data.course_data).geo_points
        )
      end

      it 'returns an Activity' do
        expect(@results.first).to be_a(Activity)
      end
    end
  end

  context 'with an existing id' do
    let(:existing_acitivity_data) { ActivityData.new(1, 'Existing walk', Time.now, []) }
    let(:new_activity_data) { ActivityData.new(1, 'New walk', Time.now, []) }

    before { activity_store.push(existing_acitivity_data) }

    it 'throws an error' do
      expect { activity_store.push(new_activity_data) }.to raise_error(PG::UniqueViolation)
    end
  end

  describe '#activity_exists_for?(id)' do
    context 'with no exisiting database record' do
      it { expect(activity_store.activity_exists_for?(1)).to be false }
    end

    context 'with an existing database record' do
      let(:acitivity_data) { ActivityData.new(1, 'Walk', Time.now, []) }

      before { activity_store.push(acitivity_data) }
      it { expect(activity_store.activity_exists_for?(acitivity_data.id)).to be true }
    end
  end

  describe '#get_all' do
    context 'with no activities' do
      it { expect(activity_store.get_all).to eq [] }
    end

    context 'with three activities at different times' do
      let(:activity_yesterday) {
        ActivityData.new(1, 'A walk', Time.now - (1 * day), [[1,1], [1,2]])
      }
      let(:activity_today) {
        ActivityData.new(2, 'A run', Time.now, [[4,1], [4,2]])
      }
      let(:activity_a_week_ago) {
        ActivityData.new(3, 'A walk', Time.now - (7 * day), [[3,1], [3,2]])
      }

      before do
        activity_store.push(activity_yesterday)
        activity_store.push(activity_today)
        activity_store.push(activity_a_week_ago)
      end

      it 'has 3 items' do
        expect(activity_store.get_all.size).to be 3
      end

      it 'returns an array of activities' do
        expect(activity_store.get_all.first).to be_an Activity
        expect(activity_store.get_all.first.course).to be_a Course
      end

      it 'returns the most recent activity first' do
        expect(activity_store.get_all.first.id).to eq activity_today.id
      end
    end
  end

  describe '#get_all' do
    context 'with no activities' do
      it { expect(activity_store.get_all).to eq [] }
    end

    context 'with two activities' do
      let(:activity_one) {
        ActivityData.new( 1, 'A walk', Time.now, [[2,1], [1,1]] )
      }
      let(:activity_two) {
        ActivityData.new( 2, 'A run', Time.now, [[4,1], [4,2]] )
      }

      before do
        activity_store.push(activity_one)
        activity_store.push(activity_two)
      end

      it 'has 2 items' do
        expect(activity_store.get_all.size).to be 2
      end

      it 'returns 2 items of Activities, with Courses' do
        expect(activity_store.get_all.first).to be_an Activity
        expect(activity_store.get_all.first.course).to be_a Course
      end
    end
  end

  describe '#get_most_recent_activity_start_time' do
    context 'with no activities' do
      it {
        expect(activity_store.get_most_recent_activity_start_time).to be nil
      }

    end

    context 'with two activities at different times' do
      let(:recent_activity) {
        ActivityData.new( 1, 'A run', Time.now - (1 * day), [[4,1], [4,2]] )
      }
      let(:old_activity) {
        ActivityData.new( 2, 'A walk', Time.now - (7 * day), [[2,1], [1,1]] )
      }

      before do
        activity_store.push(recent_activity)
        activity_store.push(old_activity)
      end

      it 'returns the most recent start time' do
        expect(activity_store.get_most_recent_activity_start_time).to eq(
          recent_activity.started_at.strftime('%Y-%m-%d %H:%M:%S')
        )
      end
    end
  end

  after do
    connection.close
  end

end
