public class Main {
    public static void main(String[] args) {
        System.out.println("Starting CPU burner demo...");
        while (true) {
            burnCPU();
        }
    }

    private static double burnCPU() {
        double x = 0;
        for (int i = 0; i < 50000; i++) {
            x += Math.pow(Math.random(), Math.random());
        }
        return x;
    }
}
