exec = titan
CXX = g++
SRC = $(wildcard src/*.cc)
OBJ = $(SRC:.cc=.o)
CXXFLAGS = -std=c++20 -Wall -O3 -march=native
LDFLAGS = -lboost_locale -flto

$(exec): $(OBJ)
	$(CXX) $(OBJ) $(CXXFLAGS) -o $(exec) $(LDFLAGS)

%.o: %.cc include/%.hh
	$(CXX) -c $(CXXFLAGS) $< -o $@ $(LDFLAGS)

clean:
	clear
	rm src/*.o