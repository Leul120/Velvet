package com.velvet.api.notify.push;

public interface PushGateway {
    /** @return provider message id or "LOGGED" */
    String send(String deviceToken, String title, String body);
}
