package com.velvet.api.notify.sms;

public interface SmsGateway {
    /** @return provider message id or "LOGGED" */
    String send(String e164Phone, String message);
}
