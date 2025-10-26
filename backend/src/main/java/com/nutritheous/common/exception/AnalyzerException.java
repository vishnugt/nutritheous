package com.nutritheous.common.exception;

public class AnalyzerException extends RuntimeException {
    public AnalyzerException(String message) {
        super(message);
    }

    public AnalyzerException(String message, Throwable cause) {
        super(message, cause);
    }
}
