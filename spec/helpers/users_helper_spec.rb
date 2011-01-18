require 'spec_helper'

describe UsersHelper do
  describe 'rank_title' do
    {1 => 'private', 2 => 'sergeant', 3 => 'lieutenant', 4 => 'major'}
      .each do |rank, name|
        it "should match rank #{rank} to #{name}." do
          user = Factory :user
          user.rank = rank
          rank_title(user).should == name
        end
    end
    
    it "should label contributers as 'colonel'" do
      rank_title(Factory(:user, email: 'adam.durandal@gmail.com'))
        .should == 'colonel'
    end
  end
end
