package com.velvet.api.admin.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminPageController {

    @GetMapping({"/admin", "/admin/"})
    public String admin() {
        return "redirect:/admin/index.html";
    }

    @GetMapping({"/partner", "/partner/"})
    public String partner() {
        return "redirect:/partner/index.html";
    }

    @GetMapping({"/waitlist", "/waitlist/"})
    public String waitlist() {
        return "redirect:/waitlist/index.html";
    }

    @GetMapping({"/legal", "/legal/"})
    public String legal() {
        return "redirect:/legal/index.html";
    }
}
