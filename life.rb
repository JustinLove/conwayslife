require 'rubygems'
require 'spec'


class Life
  attr_reader :live_cells
  
  def initialize(live_cells)
    @live_cells = live_cells
  end
  
  def to_a
    @live_cells
  end
  
  def next_generation
    next_gen = []
    alive_neighbors.each do |cell,count|
      next_gen << cell if alive_next(count, live_cells.include?(cell))
    end
    self.class.new(next_gen)
  end
  
  def alive_neighbors
    h = Hash.new(0)
    live_cells.each do |x,y|
      ((x-1)..(x+1)).each do |u|
        ((y-1)..(y+1)).each do|v|
          h[[u,v]] += 1 if ([u,v] != [x,y])
        end
      end
    end
    h
  end
  
  def alive_next(n, alive_now=true)
    if alive_now
      (n >= 2 && n <= 3)
    else
      (n == 3)
    end
  end
end

describe Life do
  before do
    @live_cells = [[1, 1], [2, 2]]
    @subject = Life.new(@live_cells)
  end
  
  it "should exist" do
    @subject.should_not be_nil
  end
  
  it "should have a serialization" do
    @subject.to_a.should == @live_cells
  end
  
  it "should advance generations" do
    x = @subject.next_generation
    x.should be_kind_of Life
  end
  
  it "should kill a cell with 0 neigboors" do
    x = Life.new([[1,1]])
    y = x.next_generation
    y.to_a.should_not include([1,1])
  end
  
  context "oscillator" do
    it "should return the next generation" do
      first = Life.new([[1,2], [2,2], [3,2]])
      gen = first.next_generation
      [[2,1],[2,2], [2,3]].each do |cell|
        gen.live_cells.should include cell
      end
    end
  end
    
  context "creating live neighbor hash" do
    it "should return a hash for a single coordinate" do
      Life.new([[1,1]]).alive_neighbors.should == {
        [0,0] => 1,
        [0,1] => 1,
        [0,2] => 1,
        
        [1,0] => 1,
        [1,2] => 1,
        
        [2,0] => 1,
        [2,1] => 1,
        [2,2] => 1
      }
    end

    it "should return a hash for multiple coordinates" do
      Life.new([[1,1],[1,2]]).alive_neighbors.should == {
        [0,0] => 1,
        [0,1] => 2,
        [0,2] => 2,
        [0,3] => 1,

        [1,0] => 1,
        [1,1] => 1,
        [1,2] => 1,
        [1,3] => 1,

        [2,0] => 1,
        [2,1] => 2,
        [2,2] => 2,
        [2,3] => 1
      }
    end
  end
  
  context "the rules" do
    context "a live cell on the next generation" do

      it "should be dead with 0 live neighbors" do
        @subject.alive_next(0).should be_false
      end

      it "should be dead with 1 live neighbors" do
        @subject.alive_next(1).should be_false
      end

      it "should be alive with 2 live neighbors" do
        @subject.alive_next(2).should be_true
      end

      it "should be alive with 3 live neighbors" do
        @subject.alive_next(3).should be_true
      end

      it "should be dead with 4 live neighbors" do
        @subject.alive_next(4).should be_false
      end
    end

    context "a dead cell on the next generation" do
      it "should be alive with 3 live neighbors" do
        @subject.alive_next(3, false).should be_true
      end

      it "should be dead with 2 live neighbors" do
        @subject.alive_next(2, false).should be_false
      end
    end
  end
end              
