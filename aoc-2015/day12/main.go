package main

import (
	"os"
	"strconv"
	"strings"
)

type tokenType int

const (
	tokenString tokenType = iota
	tokenNumber
	tokenObject
	tokenList
)

func (t tokenType) String() string {
	return [...]string{"string", "number", "object", "list"}[t]
}

type token struct {
	typ      tokenType
	startPos int
	endPos   int
	children []token
}

type parser struct {
	value  string
	i      int
	tokens []token
}

func main() {
	v, _ := os.ReadFile("input.txt")
	json := string(v)
	p := parser{value: json, tokens: make([]token, 0)}
	p.parse()
	root := p.tokens[len(p.tokens)-1]

	println("Part1:", traverse(&p, &root, false))
	println("Part2:", traverse(&p, &root, true))
}

func traverse(p *parser, t *token, skipRed bool) int {
	var total int
	switch t.typ {
	case tokenNumber:
		v, _ := strconv.Atoi(p.value[t.startPos:t.endPos])
		total = v
	case tokenString:
		total = 0
	case tokenList:
		for _, v := range t.children {
			total += traverse(p, &v, skipRed)
		}
	case tokenObject:
		for i := 1; i < len(t.children); i += 2 {
			c := t.children[i]
			if skipRed && p.value[c.startPos:c.endPos] == "red" {
				return 0
			}
			total += traverse(p, &c, skipRed)
		}
	default:
		return -1
	}
	return total
}

func (p *parser) parse() token {
	p.consumeFormatting()
	var v token
	if p.peek() == '{' {
		p.consume('{')
		v = p.consumeObject()
		p.tokens = append(p.tokens, v)
		p.consume('}')
	} else if p.peek() == '[' {
		p.consume('[')
		v = p.consumeList()
		p.tokens = append(p.tokens, v)
		p.consume(']')
	} else if p.peek() == '"' {
		p.consume('"')
		v = p.consumeString()
		p.tokens = append(p.tokens, v)
		p.consume('"')
	} else if (p.peek() >= '0' && p.peek() <= '9') || p.peek() == '-' {
		v = p.consumeNumber()
		p.tokens = append(p.tokens, v)
	}
	return v
}

func (p *parser) consumeFormatting() {
	for p.peek() == ' ' || p.peek() == '\n' {
		p.consume(p.peek())
	}
}

func (p *parser) consumeString() token {
	startPos := p.i
	for p.peek() != '"' {
		p.consume(p.peek())
	}
	endPos := p.i
	return token{typ: tokenString, startPos: startPos, endPos: endPos}
}

func (p *parser) peek() byte {
	if p.i == len(p.value) {
		return 0
	}
	return p.value[p.i]
}

func (p *parser) consumeNumber() token {
	startPos := p.i
	for {
		v1 := p.peek()
		if v1 >= '0' && v1 <= '9' || v1 == '-' {
			p.consume(p.peek())
		} else {
			break
		}
	}
	endPos := p.i
	return token{typ: tokenNumber, startPos: startPos, endPos: endPos}
}

func (p *parser) consumeList() token {
	startPos := p.i
	children := make([]token, 0)
	for p.peek() != ']' {
		v := p.parse()
		children = append(children, v)
		if p.peek() == ',' {
			p.consume(',')
		} else {
			break
		}
	}
	endPos := p.i
	return token{typ: tokenList, children: children, startPos: startPos, endPos: endPos}
}

func (p *parser) consumeObject() token {
	startPos := p.i
	children := make([]token, 0)
	for p.peek() != '}' {
		k := p.parse()
		p.consume(':')
		v := p.parse()
		children = append(children, k)
		children = append(children, v)
		if p.peek() == ',' {
			p.consume(',')
		} else {
			break
		}
	}
	endPos := p.i
	return token{typ: tokenObject, children: children, startPos: startPos, endPos: endPos}
}

func (p *parser) consume(what byte) (bool, byte) {
	value := p.peek()
	if value == what {
		p.i++
		return true, value
	} else {
		return false, 0
	}
}

func prettyPrint(p *parser, tokens []token, indent int) {
	for _, t := range tokens {
		value := p.value[t.startPos:t.endPos]
		println(strings.Repeat(" ", indent), t.typ.String(), " : ", value)
		if len(t.children) > 0 {
			println(strings.Repeat(" ", indent), "children:")
			prettyPrint(p, t.children, indent+2)
		}
	}
}
