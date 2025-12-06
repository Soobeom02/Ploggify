package com.team.backend.dto;

public class TrashData {
    private int plastic;
    private int glass;
    private int paper;
    private int can;

    public TrashData(int plastic, int glass, int paper,int can) {
        this.plastic = plastic;
        this.glass = glass;
        this.paper = paper;
        this.can = can;
    }

    public int getPlastic() {
        return plastic;
    }
    public void setPlastic(int plastic) {
        this.plastic = plastic;
    }

    public int getGlass() {
        return glass;
    }
    public void setGlass(int glass) {
        this.glass = glass;
    }

    public int getPaper() {
        return paper;
    }
    public void setPaper(int paper) {
        this.paper = paper;
    }

    public int getCan() {
        return can;
    }
    public void setCan(int can) {
        this.can = can;
    }
}
