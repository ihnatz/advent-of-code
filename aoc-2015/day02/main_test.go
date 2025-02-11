package main

import "testing"

func TestCalculatePaper(t *testing.T) {
	tests := []struct {
		w         int
		h         int
		l         int
		wantPaper int
	}{
		{2, 3, 4, 58},
		{1, 1, 10, 43},
	}

	for _, tt := range tests {
		square := CalculatePaper(tt.w, tt.h, tt.l)

		if square != tt.wantPaper {
			t.Errorf("input [%d, %d, %d] want %d, got %d", tt.w, tt.h, tt.l, tt.wantPaper, square)
		}
	}
}

func TestCalculateRibbon(t *testing.T) {
	tests := []struct {
		w          int
		h          int
		l          int
		wantRibbon int
	}{
		{2, 3, 4, 34},
		{1, 1, 10, 14},
	}

	for _, tt := range tests {
		square := CalculateRibbon(tt.w, tt.h, tt.l)

		if square != tt.wantRibbon {
			t.Errorf("input [%d, %d, %d] want %d, got %d", tt.w, tt.h, tt.l, tt.wantRibbon, square)
		}
	}
}
