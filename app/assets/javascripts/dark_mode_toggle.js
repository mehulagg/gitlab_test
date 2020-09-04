export const initDarkModeToggle = () => {
    console.log("oy! 1")
    $('.js-toggle-dark-mode a').on('click', function(e) {
        e.preventDefault();

        const isCurrentlyDarkMode = $('body.gl-dark').length > 0;

        fetch("/profile/preferences", {
                "headers": {
                    "accept": "*/*;q=0.5, text/javascript, application/javascript, application/ecmascript, application/x-ecmascript",
                    "accept-language": "en-US,en;q=0.9",
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
                    "sec-fetch-dest": "empty",
                    "sec-fetch-mode": "cors",
                    "sec-fetch-site": "same-origin",
                    "x-csrf-token": $('meta[name="csrf-token"]').attr('content'),
                    "x-requested-with": "XMLHttpRequest"
                },
                "referrerPolicy": "origin-when-cross-origin",
                "body": `utf8=%E2%9C%93&_method=put&user%5Btheme_id%5D=${isCurrentlyDarkMode ? 1 : 11}`,
                "method": "POST",
                "mode": "cors",
                "credentials": "include"
            })
            .then(() => window.location.reload());
    });
}
