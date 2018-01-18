package dbutil

import (
	"io/ioutil"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

type DBUtilSuite struct {
	suite.Suite
}

func (suite *DBUtilSuite) TestMD5() {
	hashes := [][]string{
		{"test string", "6f8db599de986fab7a21625b7916589c"},
		{"Здравствуйте", "66a2e20820c3e976765ccb17b1b7adca"},
		{"a multiline\nstring!", "9beef1614897510967755a19341e730d"}}

	for _, hash := range hashes {
		assert.Equal(suite.T(), hash[1], md5hash(hash[0]))
	}
}

func readFile(filename string) string {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	return string(data)
}

func (suite *DBUtilSuite) TestDiff() {
	a := readFile("./testdata/a.txt")
	b := readFile("./testdata/b.txt")
	c := readFile("./testdata/c.txt")

	ab := readFile("./testdata/ab.diff")
	ac := readFile("./testdata/ac.diff")

	abDiff, err := diff("a.txt", "b.txt", a, b)

	assert := suite.Assert()
	assert.Nil(err)
	assert.Equal(ab, abDiff)

	acDiff, err := diff("a.txt", "c.txt", a, c)

	assert.Nil(err)
	assert.Equal(ac, acDiff)
}

func TestDBUtil(t *testing.T) {
	suite.Run(t, new(DBUtilSuite))
}
